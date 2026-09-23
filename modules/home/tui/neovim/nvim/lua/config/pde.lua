local M = {}
local uv = vim.uv

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Java / PDE" })
end

local function server_log_handler()
  local default_handler = vim.lsp.handlers["window/logMessage"]
  local pending
  return function(err, result, ctx, config)
    -- Preserve complete server messages/stack traces in the normal LSP log.
    if default_handler then
      default_handler(err, result, ctx, config)
    end
    if err or not result or result.type ~= vim.lsp.protocol.MessageType.Error then
      return
    end
    if not pending then
      pending = { count = 0, summaries = {}, seen = {} }
      -- A failed target can emit hundreds of errors. Bound the notification
      -- size and batch the burst, without delaying it until the server is quiet.
      vim.defer_fn(function()
        local batch = pending
        pending = nil
        if vim.lsp.get_client_by_id(ctx.client_id) then
          notify(
            ("PDE/JDT LS reported %d error(s):\n%s\nInspect :JdtShowLogs for full details."):format(
              batch.count,
              table.concat(batch.summaries, "\n")
            ),
            vim.log.levels.ERROR
          )
        end
      end, 1000)
    end
    local message = result.message or "Unknown server error"
    local summary = message:match("[^\r\n]+") or "Unknown server error"
    if message:find("jdk.xml.maxGeneralEntitySizeLimit", 1, true) then
      summary = "Target metadata exceeds the XML parser limit. Check the PDE launcher."
    elseif
      message:find("current target platform contains errors", 1, true)
      or message:find("Problems occurred while resolving the target contents", 1, true)
    then
      summary = "Target platform resolution failed."
    end
    summary = summary:sub(1, 240)
    pending.count = pending.count + 1
    if #pending.summaries < 3 and not pending.seen[summary] then
      pending.seen[summary] = true
      pending.summaries[#pending.summaries + 1] = summary
    end
  end
end

local function read_json(path)
  local ok, value = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  assert(ok and type(value) == "table", "Cannot read JSON configuration: " .. path)
  return value
end

local function canonical(path)
  return uv.fs_realpath(path) or vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function inside(path, directory)
  return path == directory or path:sub(1, #directory + 1) == directory .. "/"
end

function M.root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.fn.getcwd()
  end
  local root = vim.fs.root(canonical(path), "javaConfig.json")
  assert(root, "No javaConfig.json found above the current file or directory")
  return canonical(root)
end

local function target_path(root, path)
  assert(type(path) == "string" and path ~= "", "Set targetPlatform in javaConfig.json")
  path = canonical(path:sub(1, 1) == "/" and path or root .. "/" .. path)
  assert(vim.fn.filereadable(path) == 1 and path:match("%.target$"), "Target file not found: " .. path)
  local content = table.concat(vim.fn.readfile(path), "\n")
  assert(
    not content:match("type%s*=%s*['\"]Targlet['\"]"),
    "Oomph targlets are not supported; select a conventional .target file"
  )
  return path
end

function M.workspace(root)
  local config = read_json(root .. "/javaConfig.json")
  assert(
    type(config.projects) == "table" and vim.islist(config.projects) and #config.projects > 0,
    "javaConfig.json must list the projects to import"
  )
  assert(config.eclipseInstallation == nil, "This PDE profile uses targetPlatform, not eclipseInstallation")
  -- The importer rereads the JSON and uses new File(root, target), which does
  -- not handle absolute child paths. Explicit reloads accept absolute paths.
  assert(
    type(config.targetPlatform) == "string" and config.targetPlatform:sub(1, 1) ~= "/",
    "targetPlatform must be relative to javaConfig.json"
  )
  local projects, seen = {}, {}
  for _, path in ipairs(config.projects) do
    assert(
      type(path) == "string" and path ~= "" and path:sub(1, 1) ~= "/",
      "Project paths must be relative to javaConfig.json"
    )
    local project = canonical(root .. "/" .. path)
    assert(project ~= root and inside(project, root), "List individual projects inside the workspace: " .. path)
    assert(vim.fn.filereadable(project .. "/.project") == 1, "Missing .project: " .. path)
    if not seen[project] then
      projects[#projects + 1] = project
      seen[project] = true
    end
  end
  table.sort(projects)
  local formatter
  if config.formatter ~= nil then
    local value = config.formatter
    assert(type(value) == "table" and type(value.path) == "string" and value.path ~= "", "Set formatter.path")
    assert(
      type(value.profile) == "string" and value.profile:match("%S"),
      "Set formatter.profile to the XML profile name"
    )
    local path = canonical(value.path:sub(1, 1) == "/" and value.path or root .. "/" .. value.path)
    assert(vim.fn.filereadable(path) == 1, "Formatter file not found: " .. path)
    formatter = { url = vim.uri_from_fname(path), profile = value.profile }
  end
  return { root = root, projects = projects, target = target_path(root, config.targetPlatform), formatter = formatter }
end

local function selected(buf, workspace)
  if not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].filetype ~= "java" then
    return false
  end
  local path = canonical(vim.api.nvim_buf_get_name(buf))
  -- A nested project must be explicitly listed even when its parent is listed.
  local owner = vim.fs.root(path, ".project")
  return owner ~= nil and vim.tbl_contains(workspace.projects, canonical(owner))
end

function M.build_config(workspace, tools)
  assert(vim.fn.executable(tools.jdtls or "") == 1, "Missing Nix JDT LS; activate the Home Manager configuration")
  assert(vim.fn.executable(tools.flock or "") == 1, "Missing flock executable")
  assert(vim.fn.isdirectory(tools.javaHome or "") == 1, "Missing server JDK")
  local bundles = read_json(tools.bundles)
  assert(vim.islist(bundles) and #bundles > 0, "PDE bundle manifest is empty")
  for _, bundle in ipairs(bundles) do
    assert(vim.fn.filereadable(bundle) == 1, "Missing PDE bundle: " .. bundle)
  end
  local base = vim.fn.stdpath("cache") .. "/jdtls-pde/" .. vim.fn.sha256(workspace.root):sub(1, 16)
  -- A changed selection must not leave removed projects in the Eclipse workspace.
  local generation = vim.fn.sha256(table.concat(workspace.projects, "\n")):sub(1, 16)
  local state = base .. "/" .. generation
  -- Equinox persists bundle locations. Nix upgrades need a fresh runtime cache,
  -- but must keep the selected projects' workspace and indexes.
  local bundle_paths = vim.deepcopy(bundles)
  table.sort(bundle_paths)
  local runtime_key = vim.fn
    .sha256(vim.json.encode({
      canonical(tools.jdtls),
      canonical(tools.javaHome),
      bundle_paths,
    }))
    :sub(1, 16)
  local runtime = state .. "/config-" .. runtime_key
  local runtimes = { { name = "JavaSE-25", path = tools.javaHome, default = true } }
  if vim.env.PDE_JAVA_23_HOME and vim.env.PDE_JAVA_23_HOME ~= "" then
    runtimes[#runtimes + 1] = { name = "JavaSE-23", path = vim.env.PDE_JAVA_23_HOME }
  end
  for _, runtime in ipairs(vim.g.pde_java_runtimes or {}) do
    runtimes = vim.tbl_filter(function(existing)
      return existing.name ~= runtime.name
    end, runtimes)
    runtimes[#runtimes + 1] = runtime
  end
  for _, runtime in ipairs(runtimes) do
    assert(vim.fn.executable(runtime.path .. "/bin/java") == 1, "Invalid Java runtime: " .. runtime.path)
  end
  local config = {
    name = "jdtls",
    root_dir = workspace.root,
    cmd_cwd = workspace.root,
    cmd = {
      tools.flock,
      "--nonblock",
      "--conflict-exit-code",
      "73",
      base .. "/server.lock",
      tools.jdtls,
      "--jvm-arg=-Xms512m",
      "--jvm-arg=-Xmx6g",
      "--jvm-arg=-XX:+UseG1GC",
      "-configuration",
      runtime,
      "-data",
      state .. "/workspace",
    },
    init_options = { bundles = bundles },
    handlers = { ["window/logMessage"] = server_log_handler() },
    settings = {
      java = {
        autobuild = { enabled = false },
        maxConcurrentBuilds = 1,
        configuration = { runtimes = runtimes, updateBuildConfiguration = "disabled" },
        import = {
          maven = { enabled = false },
          gradle = { enabled = false },
          generatesMetadataFilesAtProjectRoot = false,
          -- PDE imports its explicit list directly. Block the fallback Eclipse
          -- importer, which otherwise scans and imports the entire checkout.
          exclusions = { "**" },
        },
        -- Nonempty resource filters are persisted into existing .project files.
        project = { resourceFilters = {} },
        referencesCodeLens = { enabled = false },
        implementationsCodeLens = { enabled = false },
        saveActions = { organizeImports = false },
        format = { onType = { enabled = false } },
      },
    },
    flags = { debounce_text_changes = 300 },
  }
  if workspace.formatter then
    -- JDT LS also overwrites XML tab settings with java.format defaults.
    -- Parse the selected profile once at startup using a real XML parser;
    -- never scan projects or guess indentation from source-file contents.
    local python = tools.python or vim.fn.exepath("python3")
    assert(vim.fn.executable(python) == 1, "Missing Python XML reader; activate Home Manager")
    local parsed = vim
      .system({
        python,
        "-c",
        [=[
import json, sys, xml.etree.ElementTree as ET
try:
    root = ET.parse(sys.argv[1]).getroot()
    profiles = [p for p in root.iter("profile") if p.get("name") == sys.argv[2]]
    if len(profiles) != 1:
        raise ValueError("expected exactly one profile named " + sys.argv[2])
    settings = {s.get("id"): s.get("value") for s in profiles[0].findall("setting")}
    prefix = "org.eclipse.jdt.core.formatter."
    kind = settings.get(prefix + "tabulation.char")
    size = int(settings.get(prefix + "tabulation.size", "0"))
    if kind not in ("tab", "space") or size <= 0:
        raise ValueError("profile must specify tab or space indentation and a positive tabulation.size")
    print(json.dumps({"insertSpaces": kind == "space", "tabSize": size}))
except (OSError, ET.ParseError, ValueError) as error:
    sys.exit(str(error))
]=],
        vim.uri_to_fname(workspace.formatter.url),
        workspace.formatter.profile,
      }, { text = true })
      :wait(5000)
    assert(parsed.code == 0, "Cannot load formatter profile: " .. (parsed.stderr or "XML reader failed"))
    local indentation = vim.json.decode(parsed.stdout)
    config.settings.java.format.insertSpaces = indentation.insertSpaces
    config.settings.java.format.tabSize = indentation.tabSize
    config.settings.java.format.settings = workspace.formatter
  end
  -- These must reach initialize, before any import/build/filter job starts.
  config.init_options.settings = vim.deepcopy(config.settings)
  return config, state, runtime
end

local function sync_formatter(client, buf)
  local state = client.config._pde
  if not state.ready or not state.workspace.formatter or not selected(buf, state.workspace) then
    return
  end
  local uri = vim.uri_from_bufnr(buf)
  local prefix = "org.eclipse.jdt.core.formatter."
  client:request("workspace/executeCommand", {
    command = "java.project.getSettings",
    arguments = { uri, { prefix .. "tabulation.char", prefix .. "tabulation.size", prefix .. "lineSplit" } },
  }, function(err, settings)
    if
      vim.lsp.get_client_by_id(client.id) ~= client
      or client:is_stopped()
      or client.config._pde ~= state
      or not selected(buf, state.workspace)
      or vim.uri_from_bufnr(buf) ~= uri
    then
      return
    end
    if err or type(settings) ~= "table" then
      notify("Cannot read Java formatter preferences; inspect :JdtShowLogs and restart PDE.", vim.log.levels.WARN)
      return
    end
    local kind = settings[prefix .. "tabulation.char"]
    local size = tonumber(settings[prefix .. "tabulation.size"])
    local width = tonumber(settings[prefix .. "lineSplit"])
    if (kind ~= "tab" and kind ~= "space") or not size or size < 1 or size % 1 ~= 0 then
      notify(
        "Unsupported Java formatter indentation (expected tab or space with a positive tab size).",
        vim.log.levels.WARN
      )
      return
    end
    -- LSP formatting overrides JDT's tab character/size with these buffer
    -- options. Read the effective project preferences, including XML defaults
    -- and any project-specific overrides, only for attached Java buffers.
    vim.bo[buf].expandtab = kind == "space"
    vim.bo[buf].tabstop = size
    vim.bo[buf].shiftwidth = size
    vim.bo[buf].softtabstop = size
    if width and width >= 0 and width % 1 == 0 then
      vim.bo[buf].textwidth = width
    end
  end, buf)
end

-- A cmd factory runs for every new process, including native :lsp restart,
-- which otherwise reuses the old Client.config verbatim.
local function launch(dispatchers, config)
  local workspace = M.workspace(config.root_dir)
  local tools = read_json((vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")) .. "/nvim-pde/tools.json")
  local generated, state, runtime = M.build_config(workspace, tools)
  -- Client.create already references these tables when it calls the factory.
  -- Mutate their contents so initialize and didChangeConfiguration agree.
  config.settings.java = generated.settings.java
  config.handlers["window/logMessage"] = generated.handlers["window/logMessage"]
  config.init_options = generated.init_options
  config.init_options.extendedClientCapabilities = vim.deepcopy(require("jdtls.capabilities"))
  config._pde = { workspace = workspace, state = state, ready = false }
  vim.fn.mkdir(runtime, "p")
  vim.fn.mkdir(state .. "/workspace", "p")
  notify(
    ("Starting PDE for %d selected projects; references cover this selection. Heap limit: 6 GB."):format(
      #workspace.projects
    )
  )
  return vim.lsp.rpc.start(generated.cmd, dispatchers, { cwd = workspace.root })
end

local function root_dir(buf, on_dir)
  if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
    return
  end
  local ok, root = pcall(M.root, vim.api.nvim_buf_get_name(buf))
  if not ok then
    return
  end
  local workspace
  for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls", _uninitialized = true })) do
    if client.config.root_dir == root and not client:is_stopped() and client.config._pde then
      workspace = client.config._pde.workspace
      break
    end
  end
  if selected(buf, workspace or M.workspace(root)) then
    on_dir(root)
  end
end

local function current_client()
  for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls", bufnr = 0 })) do
    if client.config._pde then
      return client
    end
  end
  local ok, root = pcall(M.root)
  if ok then
    for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
      if client.config._pde and client.config.root_dir == root then
        return client
      end
    end
  end
end

local function guarded(fn)
  return function(...)
    local ok, err = pcall(fn, ...)
    if not ok then
      notify(tostring(err), vim.log.levels.ERROR)
    end
  end
end

function M.reload_target(path)
  local client = current_client()
  assert(client and not client:is_stopped(), "Enable jdtls and wait for initialization before reloading a target")
  local root = client.config.root_dir
  local commands = (client.server_capabilities.executeCommandProvider or {}).commands or {}
  assert(
    vim.tbl_contains(commands, "java.pde.reloadTargetPlatform"),
    "PDE reload command unavailable; inspect :JdtShowLogs for bundle errors"
  )
  local target = target_path(root, path ~= "" and path or read_json(root .. "/javaConfig.json").targetPlatform)
  local sent = client:request("workspace/executeCommand", {
    command = "java.pde.reloadTargetPlatform",
    arguments = { vim.uri_from_fname(target) },
  }, function(err)
    if err then
      notify("Target reload failed: " .. err.message, vim.log.levels.ERROR)
    else
      -- The extension schedules a background job; this reply is not completion.
      notify("Target reload scheduled. Watch LSP progress and :JdtShowLogs for resolution errors.")
    end
  end)
  assert(sent, "Could not send PDE target reload request")
end

function M.setup()
  vim.api.nvim_create_user_command(
    "PdeReloadTarget",
    guarded(function(args)
      M.reload_target(args.fargs[1] or "")
    end),
    { nargs = "?", complete = "file", desc = "Reload the PDE target platform" }
  )
  vim.api.nvim_create_user_command(
    "JdtShowLogs",
    guarded(function()
      local client = current_client()
      assert(client, "Open a buffer in a running PDE workspace first")
      vim.api.nvim_cmd({ cmd = "split", args = { client.config._pde.state .. "/workspace/.metadata/.log" } }, {})
      vim.api.nvim_cmd({ cmd = "vsplit", args = { vim.lsp.log.get_filename() } }, {})
    end),
    { desc = "Open PDE and Neovim language-server logs" }
  )
  local ok, blink = pcall(require, "blink.cmp")
  -- Blink only supplies completion capabilities unless Neovim defaults are requested.
  local capabilities = ok and blink.get_lsp_capabilities(nil, true) or vim.lsp.protocol.make_client_capabilities()
  local kinds = capabilities.textDocument.codeAction.codeActionLiteralSupport.codeActionKind.valueSet
  for _, kind in ipairs({ "source.generate.toString", "source.generate.hashCodeEquals", "source.organizeImports" }) do
    if not vim.tbl_contains(kinds, kind) then
      kinds[#kinds + 1] = kind
    end
  end
  vim.lsp.config("jdtls", {
    cmd = launch,
    root_dir = guarded(root_dir),
    workspace_required = true,
    filetypes = { "java" },
    capabilities = capabilities,
    settings = {},
    flags = { debounce_text_changes = 300 },
    exit_timeout = 10000,
    on_exit = function(code)
      if code == 73 then
        notify("Another Neovim process owns this PDE workspace; stop that server first.", vim.log.levels.WARN)
      end
    end,
    handlers = {
      ["language/status"] = function(err, result, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if not err and result and result.type == "ServiceReady" and client and not client:is_stopped() then
          client.config._pde.ready = true
          for buf in pairs(client.attached_buffers) do
            sync_formatter(client, buf)
          end
        end
      end,
    },
    on_init = function(client)
      -- Native restart reattaches old buffers. Prune removed projects before
      -- didOpen, and attach any newly selected projects already open in Neovim.
      for buf in pairs(client.attached_buffers) do
        if vim.bo[buf].buftype == "" and not selected(buf, client.config._pde.workspace) then
          vim.lsp.buf_detach_client(buf, client.id)
        end
      end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if selected(buf, client.config._pde.workspace) then
          vim.lsp.buf_attach_client(buf, client.id)
        end
      end
    end,
    on_attach = function(client, buf)
      sync_formatter(client, buf)
      vim.b[buf].autoformat = false
      local jdtls = require("jdtls")
      for key, mapping in pairs({
        ["<leader>co"] = { jdtls.organize_imports, "Organize Imports" },
        ["<leader>cxv"] = { jdtls.extract_variable, "Extract Variable" },
        ["<leader>cxc"] = { jdtls.extract_constant, "Extract Constant" },
      }) do
        vim.keymap.set("n", key, mapping[1], { buffer = buf, desc = mapping[2] })
      end
      -- Override plugin commands after its LspAttach callback has installed them.
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) or client:is_stopped() then
          return
        end
        vim.api.nvim_buf_create_user_command(buf, "JdtRestart", function()
          vim.cmd("lsp restart")
        end, { desc = "Restart using Neovim's LSP lifecycle" })
        vim.api.nvim_buf_create_user_command(buf, "JdtWipeDataAndRestart", function()
          notify("Cache wiping is disabled. Use :lsp restart instead.", vim.log.levels.WARN)
        end, { desc = "PDE cache wiping is not supported" })
      end)
    end,
  })
  vim.lsp.enable("jdtls")
end

return M
