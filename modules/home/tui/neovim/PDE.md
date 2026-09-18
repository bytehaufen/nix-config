# Java / Eclipse PDE

This configuration uses `nvim-jdtls`, Nix-managed JDT LS on JDK 25, and the
Java bundles from [vscode-pde](https://github.com/testforstephen/vscode-pde).
It does not require VS Code. Activate the Home Manager configuration and let
Lazy install `nvim-jdtls` before using the commands.

## Select a small workspace

Create a local `javaConfig.json` at your checkout root. List individual Eclipse
projects, including their required source dependencies, and a conventional
PDE `.target` file. Paths are relative to this file:

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

## Commands

Open a Java file in a listed project, then run `:PdeStart`.

| Command                   | Action                                                                |
| ------------------------- | --------------------------------------------------------------------- |
| `:PdeStart`               | Start manually, or attach buffers to this workspace's existing server |
| `:PdeStop`                | Stop this workspace's server gracefully                               |
| `:PdeRestart`             | Restart and reread the project selection and target configuration     |
| `:PdeReloadTarget [path]` | Reload the configured target, or another `.target` file               |
| `:JdtShowLogs`            | Open Java language-server logs                                        |

Relative reload paths are resolved against `javaConfig.json`, not the current
working directory. Reload needs a running, initialized PDE server. It invokes
`java.pde.reloadTargetPlatform` with the target file URI. The server schedules a
background job, so an accepted request is not proof that resolution succeeded:
watch LSP progress and logs. An explicit path changes the current server's target;
update `javaConfig.json` too if it should survive a restart.

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

The initial combination was checked in a disposable two-project fixture with a
third, unlisted project: imports stayed limited to the selection, cross-project
definition lookup and completion worked, target reload was accepted, and project
metadata remained unchanged. This does not establish memory use or target
compatibility for a large production workspace.
