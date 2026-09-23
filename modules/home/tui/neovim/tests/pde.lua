-- Configuration/validation tests; never starts a language server.
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/modules/home/tui/neovim/nvim")
local root = vim.fn.tempname()
vim.env.XDG_CACHE_HOME, vim.env.XDG_STATE_HOME = root .. "/cache", root .. "/state"
vim.env.PDE_JAVA_23_HOME = nil
local function write(path, value)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(vim.split(value, "\n"), path)
end
local function json(path, value)
	write(path, vim.json.encode(value))
end
local function fails(fn, message)
	local ok, err = pcall(fn)
	assert(not ok and tostring(err):find(message, 1, true), tostring(err))
end
local repo = root .. "/checkout"
for _, name in ipairs({ "api", "nested/client" }) do
	write(repo .. "/" .. name .. "/.project", "<projectDescription/>")
	write(repo .. "/" .. name .. "/Example.java", "class Example {}")
end
write(repo .. "/fixture.target", '<target name="test"/>')
local selection = { projects = { "api", "nested/client" }, targetPlatform = "fixture.target" }
json(repo .. "/javaConfig.json", selection)
local java = vim.fn.resolve(vim.fn.exepath("java"))
local tools = {
	jdtls = vim.fn.exepath("true"),
	flock = vim.fn.exepath("true"),
	javaHome = vim.fs.dirname(vim.fs.dirname(java)),
	bundles = root .. "/bundles.json",
}
write(root .. "/fake.jar", "fixture")
json(tools.bundles, { root .. "/fake.jar" })
local pde = require("config.pde")
assert(pde.root(repo .. "/nested/client/Example.java") == repo)
local config, state = pde.build_config(pde.workspace(repo), tools)
assert(config.root_dir == repo and not state:find(repo, 1, true))
assert(vim.tbl_contains(config.cmd, "--jvm-arg=-Xmx6g"))
assert(vim.deep_equal(config.init_options.settings, config.settings))
assert(vim.deep_equal(config.settings.java.import.exclusions, { "**" }))
assert(vim.deep_equal(config.settings.java.project.resourceFilters, {}))
selection.projects = { "api" }
json(repo .. "/javaConfig.json", selection)
local _, reduced = pde.build_config(pde.workspace(repo), tools)
assert(reduced ~= state, "Removed projects must not remain in the reused workspace")
local again = pde.build_config(pde.workspace(repo), tools)
assert(config.cmd[5] == again.cmd[5], "Selections must share a checkout-wide lock")

write(
	repo .. "/team style.xml",
	[[<profiles><profile name="Other">
<setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="space"/>
<setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="2"/>
</profile><profile name="Team">
<setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="tab"/>
<setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="4"/>
</profile></profiles>]]
)
selection.formatter = { path = "./team style.xml", profile = "Team" }
json(repo .. "/javaConfig.json", selection)
local formatted = pde.build_config(pde.workspace(repo), tools)
assert(formatted.settings.java.format.settings.url == vim.uri_from_fname(repo .. "/team style.xml"))
assert(formatted.init_options.settings.java.format.settings.profile == "Team")
assert(formatted.init_options.settings.java.format.insertSpaces == false)
assert(formatted.init_options.settings.java.format.tabSize == 4)
selection.formatter.profile = "Other"
json(repo .. "/javaConfig.json", selection)
local other = pde.build_config(pde.workspace(repo), tools)
assert(other.settings.java.format.insertSpaces and other.settings.java.format.tabSize == 2)
selection.formatter.profile = "Missing"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.build_config(pde.workspace(repo), tools)
end, "expected exactly one profile")
selection.formatter.profile = ""
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "formatter.profile")
selection.formatter = { path = "missing.xml", profile = "Team" }
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "Formatter file not found")
write(repo .. "/broken.xml", "<profiles><profile>")
selection.formatter.path = "broken.xml"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.build_config(pde.workspace(repo), tools)
end, "Cannot load formatter profile")
selection.formatter = nil
selection.targetPlatform = repo .. "/fixture.target"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "targetPlatform must be relative")
selection.targetPlatform = "missing.target"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "Target file not found")
write(repo .. "/oomph.target", '<target><locations><location type="Targlet"/></locations></target>')
selection.targetPlatform = "oomph.target"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "Oomph targlets")
selection.targetPlatform = "fixture.target"
selection.projects = { "../outside" }
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "inside the workspace")
write(repo .. "/javaConfig.json", "not json")
fails(function()
	pde.workspace(repo)
end, "Cannot read JSON")

-- Keep full server logs while presenting bounded notifications for error bursts.
local notices, logged = {}, {}
vim.notify = function(message, level)
	notices[#notices + 1] = { message = message, level = level }
end
local original_handler = vim.lsp.handlers["window/logMessage"]
vim.lsp.handlers["window/logMessage"] = function(_, result)
	logged[#logged + 1] = result
end
local original_lookup = vim.lsp.get_client_by_id
local running = true
vim.lsp.get_client_by_id = function()
	return running and {} or nil
end
selection.projects = { "api" }
json(repo .. "/javaConfig.json", selection)
local logging = pde.build_config(pde.workspace(repo), tools).handlers["window/logMessage"]
logging(nil, { type = 2, message = "Warning only" }, { client_id = 1 })
assert(#notices == 0)
for _ = 1, 100 do
	logging(
		nil,
		{ type = 1, message = "Problems loading repositories\njdk.xml.maxGeneralEntitySizeLimit" },
		{ client_id = 1 }
	)
end
assert(#logged == 101)
assert(vim.wait(1500, function()
	return #notices == 1
end))
assert(notices[1].level == vim.log.levels.ERROR and notices[1].message:find("100 error(s)", 1, true))
assert(notices[1].message:find("XML parser limit", 1, true))
logging(nil, { type = 1, message = "Late error" }, { client_id = 1 })
running = false
vim.wait(1100, function()
	return false
end)
assert(#notices == 1, "Stopped clients must not emit queued notifications")
vim.lsp.handlers["window/logMessage"] = original_handler
vim.lsp.get_client_by_id = original_lookup
print("PASS: root/selection validation, caches/lock, formatter profiles, import controls, batched errors")
vim.cmd("qa!")
