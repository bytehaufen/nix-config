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
  return { root = root, projects = projects, target = target_path(root, config.targetPlatform) }
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
  config.on_attach = function(_, attached_buf)
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
  local session = { workspace = workspace }
  config.on_init = function()
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
