local M = {}
local sessions = {}
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
      state .. "/config",
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
  return config, state
end

local function current_session()
  local root = M.root()
  return sessions[root], root
end

local function attach_buffers(session)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if selected(buf, session.workspace) then
      vim.lsp.buf_attach_client(buf, session.id)
    end
  end
end

local function sync_formatter(session, buf)
  if not session.ready or not session.workspace.formatter then
    return
  end
  local client = vim.lsp.get_client_by_id(session.id)
  if not client then
    return
  end
  local uri = vim.uri_from_bufnr(buf)
  local prefix = "org.eclipse.jdt.core.formatter."
  client:request("workspace/executeCommand", {
    command = "java.project.getSettings",
    arguments = { uri, { prefix .. "tabulation.char", prefix .. "tabulation.size", prefix .. "lineSplit" } },
  }, function(err, settings)
    if
      sessions[session.workspace.root] ~= session
      or session.stopping
      or not selected(buf, session.workspace)
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

function M.start()
  local root = M.root()
  local existing = sessions[root]
  if existing then
    assert(not existing.stopping, "PDE server is still stopping")
    attach_buffers(existing)
    notify("PDE server already running. Use :PdeRestart to apply configuration changes.")
    return
  end
  local workspace = M.workspace(root)
  local buf = vim.api.nvim_get_current_buf()
  if not selected(buf, workspace) then
    buf = nil
    for _, candidate in ipairs(vim.api.nvim_list_bufs()) do
      if selected(candidate, workspace) then
        buf = candidate
        break
      end
    end
  end
  assert(buf, "Open a Java file in a project listed in javaConfig.json before :PdeStart")
  local tools = read_json((vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")) .. "/nvim-pde/tools.json")
  local config, state = M.build_config(workspace, tools)
  local ok, blink = pcall(require, "blink.cmp")
  config.capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()
  local session = { workspace = workspace, buffers = {} }
  config.on_attach = function(_, attached_buf)
    session.buffers[attached_buf] = true
    sync_formatter(session, attached_buf)
    -- nvim-jdtls installs buffer commands in LspAttach after on_attach. Replace
    -- them afterward so there is only one owner of this workspace's lifecycle.
    vim.schedule(function()
      if sessions[root] ~= session or session.stopping or not vim.api.nvim_buf_is_valid(attached_buf) then
        return
      end
      vim.api.nvim_buf_create_user_command(attached_buf, "JdtRestart", function()
        vim.cmd.PdeRestart()
      end, { desc = "Restart the managed PDE workspace" })
      vim.api.nvim_buf_create_user_command(attached_buf, "JdtWipeDataAndRestart", function()
        notify("Cache wiping is disabled for managed PDE workspaces. Use :PdeRestart.", vim.log.levels.WARN)
      end, { desc = "PDE cache wiping is not supported" })
    end)
    vim.b[attached_buf].autoformat = false
    local jdtls = require("jdtls")
    for key, mapping in pairs({
      ["<leader>co"] = { jdtls.organize_imports, "Organize Imports" },
      ["<leader>cxv"] = { jdtls.extract_variable, "Extract Variable" },
      ["<leader>cxc"] = { jdtls.extract_constant, "Extract Constant" },
    }) do
      vim.keymap.set("n", key, mapping[1], { buffer = attached_buf, desc = mapping[2] })
    end
  end
  config.on_init = function(client)
    if workspace.formatter then
      -- Install on the initialized client, outside nvim-jdtls's wrapper, which
      -- drops status notifications once its original startup buffer is wiped.
      local upstream = client.handlers["language/status"]
      client.handlers["language/status"] = function(err, result, ctx, handler_config)
        if
          not err
          and result
          and result.type == "ServiceReady"
          and sessions[root] == session
          and not session.stopping
          and not session.ready
        then
          session.ready = true
          for attached_buf in pairs(session.buffers) do
            if selected(attached_buf, workspace) then
              sync_formatter(session, attached_buf)
            end
          end
        end
        if upstream then
          return upstream(err, result, ctx, handler_config)
        end
      end
    end
    vim.schedule(function()
      if sessions[root] == session and not session.stopping then
        attach_buffers(session)
      end
    end)
  end
  config.on_exit = function(code, signal)
    vim.schedule(function()
      if sessions[root] == session then
        sessions[root] = nil
      end
      if not session.stopping then
        local message = code == 73 and "Another Neovim process owns this PDE workspace; stop that server first."
          or ("PDE server exited (code %s, signal %s). Inspect :JdtShowLogs; restart explicitly."):format(code, signal)
        notify(message, vim.log.levels.WARN)
      end
    end)
  end
  vim.fn.mkdir(state .. "/config", "p")
  vim.fn.mkdir(state .. "/workspace", "p")
  session.id = require("jdtls").start_or_attach(config, {}, { bufnr = buf })
  assert(session.id, "JDT LS failed to start; inspect :messages")
  sessions[root] = session
  notify(
    ("Starting PDE for %d selected projects; references cover this selection. Heap limit: 6 GB."):format(
      #workspace.projects
    )
  )
end

function M.stop()
  local session = current_session()
  if session then
    session.stopping = true
    local client = vim.lsp.get_client_by_id(session.id)
    if client then
      client:stop()
    else
      sessions[session.workspace.root] = nil
    end
  else
    notify("No PDE server running for this workspace")
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

function M.restart()
  local session, root = current_session()
  if not session then
    return M.start()
  end
  M.stop()
  local attempts = 0
  local function wait_for_exit()
    if not sessions[root] then
      -- Do not start in an unrelated workspace if the user changed buffers.
      if M.root() == root then
        M.start()
      else
        notify("PDE stopped. Return to its workspace and run :PdeStart.")
      end
    elseif attempts < 100 then
      attempts = attempts + 1
      vim.defer_fn(guarded(wait_for_exit), 100)
    else
      notify("PDE is still stopping; run :PdeStart after it exits.", vim.log.levels.WARN)
    end
  end
  vim.defer_fn(guarded(wait_for_exit), 100)
end

function M.reload_target(path)
  local session, root = current_session()
  local client = session and vim.lsp.get_client_by_id(session.id)
  assert(
    client and client.initialized and not session.stopping,
    "Start PDE and wait for initialization before reloading a target"
  )
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
  for name, fn in pairs({ PdeStart = M.start, PdeStop = M.stop, PdeRestart = M.restart }) do
    vim.api.nvim_create_user_command(name, guarded(fn), { desc = name:gsub("Pde", "PDE ") })
  end
  vim.api.nvim_create_user_command(
    "PdeReloadTarget",
    guarded(function(args)
      M.reload_target(args.fargs[1] or "")
    end),
    { nargs = "?", complete = "file", desc = "Reload the PDE target platform" }
  )
  local group = vim.api.nvim_create_augroup("pde-manual", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "java",
    callback = function(args)
      for _, session in pairs(sessions) do
        if not session.stopping and selected(args.buf, session.workspace) then
          vim.lsp.buf_attach_client(args.buf, session.id)
        end
      end
    end,
  })
end

return M
