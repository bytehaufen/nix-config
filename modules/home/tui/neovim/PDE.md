# Java / Eclipse PDE

This configuration uses `nvim-jdtls`, Nix-managed JDT LS on JDK 25, and the
Java bundles from [vscode-pde](https://github.com/testforstephen/vscode-pde).
It does not require VS Code. Activate the Home Manager configuration and let
Lazy install `nvim-jdtls` before using the commands.

## Select a small workspace

Create a local `javaConfig.json` at your checkout root. List individual Eclipse
projects, including their required source dependencies, and a conventional
PDE `.target` file. Project and target paths must be relative to this file
(the pinned PDE importer cannot import an absolute `targetPlatform` path):

```json
{
  "projects": ["./org.example.plugin", "./org.example.plugin.tests"],
  "targetPlatform": "./target-platform/development.target"
}
```

Keep this file untracked by adding `/javaConfig.json` to your repository's local
exclude file (`git rev-parse --git-path info/exclude`). Preserve existing entries;
the Neovim integration does not edit Git settings or create project configuration.

Oomph `Targlet` locations are not supported in this first version. Use a regular
PDE target with p2 or directory locations. A different target can resolve different
dependencies from Eclipse: check the resulting diagnostics before expanding the
selection. Private p2 repositories must be accessible to the server; Maven's
`settings.xml` does not automatically supply p2 credentials.

On Linux, the Nix launcher selects matching GLib/libsecret libraries for Equinox's
desktop-keyring integration. This avoids native-library conflicts when accessing
Eclipse's existing secure storage. The desktop keyring must be available and
unlocked in the Neovim session; no passwords belong in Nix or `javaConfig.json`.
Use HTTPS for authenticated p2 mirrors: HTTP exposes credentials in transit.

### Reuse a local Eclipse bundle pool

For a download-free **target**, use a local `pde-pool.target` instead of p2 sites:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?pde?>
<target name="PDE local bundle pool" sequenceNumber="1">
  <locations>
    <location path="/home/rico/.p2/pool/plugins" type="Directory"/>
  </locations>
  <environment>
    <os>linux</os>
    <ws>gtk</ws>
    <arch>x86_64</arch>
  </environment>
</target>
```

Adjust the path/environment for another machine. Keep `projects` unchanged in
`javaConfig.json` and set `"targetPlatform": "./pde-pool.target"`. Keep both files
out of shared commits using the checkout's `.git/info/exclude`. No Home Manager
rebuild is needed for this target-only change: run `:PdeReloadTarget` in an already
running session (it rereads the configured target path), or `:PdeStart` if stopped.

PDE reads the pool in place; it does not copy, provision, or modify its bundles.
The directory target bypasses remote p2 metadata, target downloads, and mirror
authentication. JDT LS still has its own index/workspace, and separate source or
Javadoc lookup may use the network. After Eclipse adds/removes bundles, reload the
target to rescan the directory.

This includes all cached versions, not just Eclipse's active target. Completion
and diagnostics can therefore differ from Eclipse, and missing bundles cannot be
downloaded through this target. Keep Eclipse/builds authoritative. To return to p2,
restore the previous `targetPlatform` value and restart/reload; no cache deletion
is needed. The repository's shared target and Eclipse's active target are unchanged.

### Project Java runtime

Projects requiring Java 23 need their actual runtime configured separately from
the server's JDK. Set `PDE_JAVA_23_HOME` to the installed JDK/JRE home (the directory
containing `bin/java`) before starting Neovim. For other execution environments,
set this in your local Lua configuration:

```lua
vim.g.pde_java_runtimes = {
  { name = "JavaSE-23", path = "/path/to/java-23" },
}
```

Project compiler settings remain authoritative. Custom JavaFX containers, classpath
variables, or other Eclipse-specific extensions may need additional configuration;
this integration does not import Eclipse's installed-runtime preferences.

### Checkout formatter

Add an optional formatter block to `javaConfig.json`, keeping the project list
and target unchanged:

```json
"formatter": {
  "path": "./releng/eclipse-setup/team-style.xml",
  "profile": "Team Style"
}
```

Use an exported Eclipse formatter XML file and the exact `<profile name="...">`
inside it (not Eclipse's internal underscore-prefixed preference ID). Relative
paths resolve against `javaConfig.json`; absolute local paths are also supported.
The selected XML profile is read once at startup with Python's standard XML
parser (Nix-managed; an existing `python3` is used before activation). Missing
files/profiles, malformed XML, or unsupported indentation prevent startup with
a visible error. No extra Python packages or checkout scans are needed.

After import completes, attached Java buffers read their effective formatter
preferences from JDT LS, including project-specific overrides. This sets local
tabs/spaces, tab/indent width, and line width so `<leader>cf` does not override the
XML with the editor's global two-space indentation. Other buffers are unaffected;
automatic formatting remains disabled. Wait for import before formatting.
Tab and space profiles are supported; mixed indentation profiles are rejected
because JDT LS's formatting protocol forces either tabs or spaces. A project
override using mixed indentation produces a warning instead of changing its buffer.

Run `:PdeRestart` after changing the formatter configuration or XML. Target reload
alone does not apply formatter changes. When first installing this Lua change,
stop PDE and reopen Neovim before `:PdeStart`. Buffer indentation remains set after
stopping PDE; reopen affected buffers if removing the formatter configuration.

## Commands

Open a Java file in a listed project, then run `:PdeStart`.

| Command                   | Action                                                                |
| ------------------------- | --------------------------------------------------------------------- |
| `:PdeStart`               | Start manually, or attach buffers to this workspace's existing server |
| `:PdeStop`                | Stop this workspace's server gracefully                               |
| `:PdeRestart`             | Restart and reread projects, target, and formatter configuration      |
| `:PdeReloadTarget [path]` | Reload the configured target, or another `.target` file               |
| `:JdtShowLogs`            | Open Java language-server logs                                        |

In attached PDE buffers, `:JdtRestart` aliases `:PdeRestart` so the replacement
server stays managed. `:JdtWipeDataAndRestart` is blocked: upstream cache wiping
bypasses PDE's lifecycle and selection-specific state management. No cache is
deleted by these commands.

Relative reload paths are resolved against `javaConfig.json`, not the current
working directory; explicit reload paths may also be absolute. Reload needs a
running, initialized PDE server. It invokes
`java.pde.reloadTargetPlatform` with the target file URI. The server schedules a
background job, so an accepted request is not proof that resolution succeeded:
watch LSP progress and logs. An explicit path changes the current server's target;
update `javaConfig.json` too if it should survive a restart.

Server errors sent through `window/logMessage` also produce a visible error
notification. Bursts are grouped over one second, with at most three short
summaries; full messages and stack traces remain in the logs. A disappearing
progress indicator alone is not evidence of a successful target reload.

Use the existing LSP mappings for completion, hover, definitions, references, and
code actions. `<leader>co` organizes imports; `<leader>cxv` and `<leader>cxc`
extract a variable or constant. Automatic formatting and organize-imports on save
are disabled for attached Java buffers.

## Large repositories

- Opening files never starts a server. Files in listed projects attach after an
  explicit start; other projects remain outside this session.
- Add projects manually and restart in batches. Closing a buffer does not unload
  its project. References and refactorings cover imported projects, not the whole
  repository; use Eclipse for repository-wide or cross-language refactoring.
- The maximum heap is 6 GB, with 512 MB initially allocated. Total process memory
  includes additional JVM overhead. Start with a small project selection.
- Automatic workspace builds, Maven/Gradle import, CodeLens, main-class scanning,
  and test discovery are disabled. Generated source roots remain available.
- The PDE importer reads only the explicit list. Generic import uses an exclude-all
  rule to prevent JDT LS's fallback Eclipse importer from scanning the monorepo.
  Java resource filters are empty because JDT LS persists those filters into
  `.project`; this avoids adding filter metadata to existing projects.
- State is under `stdpath("cache")/jdtls-pde/<checkout-hash>/<selection-hash>`.
  Unchanged selections reuse indexes. Changed selections use a separate workspace
  so removed projects cannot remain imported. Older caches are retained.
- A checkout-wide `flock` prevents concurrent Neovim processes from opening the
  same PDE workspace. A crashed process releases the lock automatically. A server
  exit is reported without an automatic restart loop.

The pinned PDE archive needs an additional OSGi Event API bundle with JDT LS
1.60.0; the Nix package includes that dependency. The PDE importer and JDT LS
must be upgraded and tested together. A separate
workspace directory and `generatesMetadataFilesAtProjectRoot = false` do not by
themselves guarantee that existing Eclipse metadata will remain untouched.

The Nix package patches JDT LS 1.60.0's POSIX launcher to supply the executable as
`argv[0]`. Otherwise its first JVM option is lost, including the upstream XML-limit
workaround for JDK 24+. The patch preserves the upstream JVM options; it does not
change XML limits in other applications. Its install-time regression test verifies
argument forwarding without starting Java. Revisit this patch when upgrading JDT LS.

Keep Eclipse for builds, JUnit/PDE tests, product launches, Xtend/EMF generation,
and graphical editors. Debug/test adapters and automatic project selection are
intentionally deferred.

## Validation

Run the Lua lifecycle checks without loading your normal Neovim configuration:

```sh
NVIM_LOG_FILE=/tmp/nvim-pde-tests.log nvim --headless -u NONE -l modules/home/tui/neovim/tests/pde.lua
```

These checks mock the LSP client and never start Java. Test bundle compatibility
in a disposable PDE workspace before using a new server/bundle version. Ask the
repository owner before starting a language server against their real checkout.

With the pinned `nvim-jdtls` installed, also run its real wrappers and commands
against a mocked transport. This covers wiping the startup buffer during import,
restart ownership, cache-wipe refusal, and upstream formatter settings merging:

```sh
NVIM_LOG_FILE=/tmp/nvim-pde-tests.log nvim --headless -u NONE -l modules/home/tui/neovim/tests/pde-upstream.lua
```

The optional formatter integration check starts a real server in a disposable
single-project workspace, wipes its startup buffer before import completes, tests
XML style rules and standard LSP formatting, then stops it. It requires the
activated tool manifest and installed `nvim-jdtls`:

```sh
NVIM_LOG_FILE=/tmp/pde-formatter-integration.log nvim --headless -u NONE -l modules/home/tui/neovim/tests/pde-formatter.lua
```

These checks do not establish full-monorepo memory stability, complete target
resolution, or equivalence to Eclipse's active target. Keep large-workspace
validation separate; a heap limit alone is not a stability guarantee.

After changing the Nix launcher, activate Home Manager. To load changed Lua error
handlers too, stop PDE and reopen Neovim before `:PdeStart`; `:PdeRestart` alone
does not reload an already-loaded Lua module.
