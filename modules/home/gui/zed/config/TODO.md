# Open keybinding decisions

[Current keymap](../config/keymap.json) · [Validation script](../check-keybindings.mjs)

Open and deferred keybinding decisions. Edit Suggestion and Your choice here; the
runtime keymap is the reference for implemented bindings. Source IDs and previous
choices are retained. Ignore means do not migrate; TODO means undecided. Neither
deletes existing bindings.

Category: ai.

## N0453

- Key: `<Space>ah`
- Mode: normal
- Purpose: Avante History
- Status: Discuss / approximate
- Zed option: `agent::ToggleFocus`
- Suggestion: Use native Zed agent workflows as the initial replacement; keep CLI task
  shortcuts distinct and decide provider/context behavior first.
- Caution: Choose thread sidebar/history UI; focusing alone does not open a history
  picker.
- Your choice: TODO

Category: ai.

## N0457

- Key: `<Space>ae`
- Mode: normal
- Purpose: Edit Avante
- Status: Discuss / approximate
- Zed option: `assistant::InlineAssist`
- Suggestion: Use native Zed agent workflows as the initial replacement; keep CLI task
  shortcuts distinct and decide provider/context behavior first.
- Caution: Review inline edit scope and agent/provider choice.
- Your choice: TODO

Category: ai.

## N0459

- Key: `<Space>ac`
- Mode: normal
- Purpose: Chat with Avante
- Status: Discuss / approximate
- Zed option: `agent::ToggleFocus`
- Current candidates: `task::Spawn` `{"task_name":"Codex CLI","reveal_target":"center"}`
- Suggestion: Use native Zed agent workflows as the initial replacement; keep CLI task
  shortcuts distinct and decide provider/context behavior first.
- Caution: Choose Zed agent, external agent thread, or existing CLI tasks;
  opening/focusing does not necessarily submit a prompt.
- Your choice: TODO

Category: ai.

## N0461

- Key: `<Space>aa`
- Mode: normal
- Purpose: Ask Avante
- Status: Discuss / approximate
- Zed option: `agent::ToggleFocus`
- Current candidates: `agent::ToggleFocus`
- Suggestion: Use native Zed agent workflows as the initial replacement; keep CLI task
  shortcuts distinct and decide provider/context behavior first.
- Caution: Choose Zed agent, external agent thread, or existing CLI tasks;
  opening/focusing does not necessarily submit a prompt.
- Your choice: TODO

Category: code.

## N0247 / N0249

- Key: `<Space>rF`
- Mode: visual, normal
- Purpose: Extract Function To File
- Status: Discuss / approximate
- Zed option: `editor::ToggleCodeActions`
- Suggestion: Use the code-action menu first; add a dedicated key only when the
  configured language server reliably supplies this operation.
- Caution: Availability depends on language server. A generic menu does not guarantee
  the named refactoring or documentation generation.
- Your choice: TODO

Category: code.

## N0251 / N0253

- Key: `<Space>rf`
- Mode: visual, normal
- Purpose: Extract Function
- Status: Discuss / approximate
- Zed option: `editor::ToggleCodeActions`
- Suggestion: Use the code-action menu first; add a dedicated key only when the
  configured language server reliably supplies this operation.
- Caution: Availability depends on language server. A generic menu does not guarantee
  the named refactoring or documentation generation.
- Your choice: TODO

Category: code.

## N0263 / N0265

- Key: `<Space>ri`
- Mode: visual, normal
- Purpose: Inline Variable
- Status: Discuss / approximate
- Zed option: `editor::ToggleCodeActions`
- Suggestion: Use the code-action menu first; add a dedicated key only when the
  configured language server reliably supplies this operation.
- Caution: Availability depends on language server. A generic menu does not guarantee
  the named refactoring or documentation generation.
- Your choice: TODO

Category: code.

## N0267 / N0269

- Key: `<Space>rs`
- Mode: visual, normal
- Purpose: Select Refactor
- Status: Discuss / approximate
- Zed option: `editor::ToggleCodeActions`
- Suggestion: Use the code-action menu first; add a dedicated key only when the
  configured language server reliably supplies this operation.
- Caution: Availability depends on language server. A generic menu does not guarantee
  the named refactoring or documentation generation.
- Your choice: TODO

Category: code.

## N0275 / N0277

- Key: `<Space>rx`
- Mode: visual, normal
- Purpose: Extract Variable
- Status: Discuss / approximate
- Zed option: `editor::ToggleCodeActions`
- Suggestion: Use the code-action menu first; add a dedicated key only when the
  configured language server reliably supplies this operation.
- Caution: Availability depends on language server. A generic menu does not guarantee
  the named refactoring or documentation generation.
- Your choice: TODO

Category: discoveries.

## D13 — Review individual changes inline

- Purpose: Expand a change, review it and advance through staging decisions.
- Zed options: `editor::ToggleSelectedDiffHunks`, `git::StageAndNext`,
  `git::UnstageAndNext`.
- Suggestion: Learn default.
- Caution: Ctrl-' expands selected hunks in Editor. Stage/unstage actions are
  context-sensitive and differ from Gitsigns; approve their behavior before using
  destructive/staging shortcuts.
- Key: choose later
- Your choice: TODO

Category: discoveries.

## D14 — Understand and repair key conflicts

- Purpose: Find actions, inspect their shortcuts and diagnose why a binding does not
  fire.
- Zed options: `zed::OpenKeymap`, `dev::OpenKeyContextView`.
- Suggestion: Learn default.
- Caution: Open keymap from command palette or Workspace Ctrl-k Ctrl-s; custom Ctrl-k
  navigation is a prefix conflict. Key-context view has no default in retrieved files.
- Key: choose later
- Your choice: TODO

Category: editing.

## N0439

- Key: `<Space>i`
- Mode: normal
- Purpose: Paste image from system clipboard
- Status: Discuss / none
- Zed option: No equivalent identified.
- Suggestion: Leave this unbound for the first migration pass; revisit if the missing
  behavior matters in daily use.
- Caution: Need image-file creation plus markup insertion/path rules; ordinary paste is
  not equivalent.
- Your choice: TODO

Category: tests.

## N0589

- Key: `<Space>td`
- Mode: normal
- Purpose: Debug Nearest
- Status: Discuss / none
- Zed option: No equivalent identified.
- Suggestion: Leave unbound for now. Establish a language-specific nearest-test debug
  configuration or supported debugger workflow; do not add an invented debug: true
  argument.
- Caution: nearest-task schema accepts only reveal and denies unknown fields:
  SpawnNearestTask has no debug argument and is not a verified Debug Nearest
  counterpart.
- Your choice: TODO

Category: tests.

## N0473

- Key: `<Space>oo`
- Mode: normal
- Purpose: Run task
- Status: Pending / exact
- Zed option: `task::Spawn`
- Suggestion: Add the verified action on `<Space>`oo in the matching editor/debugger
  context during a later migration pass.
- Your choice: TODO

Category: tests.

## N0493

- Key: `<Space>tl`
- Mode: normal
- Purpose: Run Last (Neotest)
- Status: Discuss / approximate
- Zed option: `task::Rerun`
- Suggestion: Reserve test keys for tests; define language-specific test tasks before
  binding them.
- Caution: Last task may not be a test. Choose named test tasks or a dedicated test
  workflow.
- Your choice: TODO (deferred in conversation; preserve Neotest file/nearest/last-test
  semantics and revisit with a real test project).

Category: tests.

## N0495

- Key: `<Space>tr`
- Mode: normal
- Purpose: Run Nearest (Neotest)
- Status: Discuss / approximate
- Zed option: `editor::SpawnNearestTask`
- Current candidates: `task::Rerun`
- Suggestion: Reserve test keys for tests; try SpawnNearestTask only with a provider
  that identifies the intended nearest test. Keep generic rerun separate.
- Caution: nearest-task schema confirms SpawnNearestTask in 1.17.2, with an optional
  reveal setting. The nearest runnable is not necessarily a test and depends on language
  task providers.
- Your choice: TODO (deferred in conversation; preserve Neotest file/nearest/last-test
  semantics and revisit with a real test project).

Category: tests.

## N0499

- Key: `<Space>tt`
- Mode: normal
- Purpose: Run File (Neotest)
- Status: Discuss / approximate
- Zed option: `task::Spawn`
- Current candidates: `task::Spawn`
- Suggestion: Reserve test keys for tests; define language-specific test tasks before
  binding them.
- Caution: Needs named language-specific test tasks with correct file/project scope;
  opening the task picker does not run these tests.
- Your choice: TODO (deferred in conversation; preserve Neotest file/nearest/last-test
  semantics and revisit with a real test project).

Category: ai.

## N0447

- Key: `<Space>ap`
- Mode: normal
- Purpose: Switch Avante Provider
- Status: Discuss / approximate
- Zed option: `agent::SelectAgent`
- Current candidates: `task::Spawn`
  `{"task_name":"Copilot CLI","reveal_target":"center"}`
- Suggestion: Use native Zed agent workflows as the initial replacement; keep CLI task
  shortcuts distinct and decide provider/context behavior first.
- Caution: Agent selection and provider selection differ; existing Space a p starts
  Copilot CLI. Catalog-only candidates need version/context verification.
- Verification: In Zed 1.17.2, SelectAgent requires an explicit agent ID. It does not
  open a picker. ToggleNewThreadMenu opens the agent/new-thread menu instead; approval
  is needed before substituting it and relocating the CLI binding.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: SelectAgent requires an agent ID. Picker substitution unresolved; existing
  Copilot CLI shortcut retained.

Category: editing.

## N0143

- Key: `<Esc>`
- Mode: select
- Purpose: Escape and Clear hlsearch
- Status: Discuss / approximate
- Zed option: `vim::SwitchToNormalMode`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: Mode escape alone does not guarantee search-highlight clearing and diff
  refresh.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Neovim Select mode has no direct Zed Vim-mode counterpart.

Category: editing.

## N0836

- Key: `gl`
- Mode: visual + select
- Purpose: Yank, paste, and comment pasted selection
- Status: Discuss / approximate
- Zed option: `editor::DuplicateSelection`; `editor::ToggleComments`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: Composite workflow: reproduce selection/cursor restoration and comment the
  correct copy. Current gl default selects another occurrence. Catalog-only candidates
  need version/context verification.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Duplicate-and-comment needs correct copy selection and cursor restoration.

Category: editing.

## N0838

- Key: `gl`
- Mode: normal
- Purpose: Yank, paste, and comment selection
- Status: Discuss / approximate
- Zed option: `editor::DuplicateSelection`; `editor::ToggleComments`
- Current candidates: `vim::SelectNext`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: Composite workflow: reproduce selection/cursor restoration and comment the
  correct copy. Current gl default selects another occurrence. Catalog-only candidates
  need version/context verification.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Duplicate-and-comment needs correct copy selection and cursor restoration.

Category: editing.

## N0840

- Key: `gcO`
- Mode: normal
- Purpose: Add Comment Above
- Status: Discuss / approximate
- Zed option: `editor::NewlineAbove`; `editor::ToggleComments`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: Composite action; confirm cursor placement, comment syntax and indentation.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Comment-line insertion needs verified indentation, cursor and Vim-mode
  sequencing.

Category: editing.

## N0842

- Key: `gco`
- Mode: normal
- Purpose: Add Comment Below
- Status: Discuss / approximate
- Zed option: `editor::NewlineBelow`; `editor::ToggleComments`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: Composite action; confirm cursor placement, comment syntax and indentation.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Comment-line insertion needs verified indentation, cursor and Vim-mode
  sequencing.

Category: editing.

## N0899 / N0901

- Key: `gx`
- Mode: visual, normal
- Purpose: Opens filepath or URI under cursor with the system handler (file explorer,
  web browser, …)
- Status: Discuss / approximate
- Zed option: `editor::OpenUrl`; `editor::OpenSelectedFilename`
- Current candidates: `editor::OpenUrl`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: URL, editor file opening and system-handler dispatch have different behavior.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: No verified single dispatcher for URL-versus-file opening in normal and
  visual mode.

Category: editing.

## N1283

- Key: `<C-S>`
- Mode: select
- Purpose: Save File
- Status: Discuss / approximate
- Zed option: `workspace::Save`
- Suggestion: Preserve save-and-return-to-normal behavior for Vim editing modes; leave
  other input fields on native Save.
- Caution: Source saves and escapes to normal mode. Native Save alone may leave
  insert/visual/select mode active; decide whether mode exit should be retained.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Neovim Select mode has no direct Zed Vim-mode counterpart.

Category: files.

## N0401

- Key: `<Space>bD`
- Mode: normal
- Purpose: Delete Buffer and Window
- Status: Discuss / approximate
- Zed option: `pane::CloseActiveItem`; `pane::JoinIntoNext`
- Suggestion: Prefer predictable item/pane closing with normal save prompts; verify
  scope before assigning a close/delete shortcut.
- Caution: Item and pane lifecycles differ; choose intended closing behavior.
  Catalog-only candidates need version/context verification.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Combined buffer-and-pane deletion needs a reliable scope-preserving
  workflow.

Category: git.

## N0017

- Key: `<Space>ghS`
- Mode: normal; buffer-local in Neovim
- Purpose: Stage Buffer
- Status: Discuss / approximate
- Zed option: `git::StageFile`
- Suggestion: Try the native Git operation from its intended UI first; bind only after
  confirming exact file/hunk scope and navigation side effects.
- Caution: Verify action targets the active editor file rather than a selected Git panel
  entry.
- Verification: In Zed 1.17.2, StageFile handles the selected Git-panel entry. It is not
  an active-editor-file staging action. Migration paused pending a decision; suggested
  fallback is to defer this binding.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: StageFile targets the Git-panel selection, not the active editor file.

Category: interface.

## N0245

- Key: `<Space>ut`
- Mode: normal
- Purpose: Toggle Treesitter Context
- Status: Discuss / approximate
- Zed option: `editor::ToggleBreadcrumb`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: Breadcrumbs are not sticky scope lines; decide whether either UI is useful.
  Catalog-only candidates need version/context verification.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Breadcrumbs are not a sticky Treesitter-context view.

Category: interface.

## N0363

- Key: `<Space>uT`
- Mode: normal
- Purpose: Toggle Treesitter Highlight
- Status: Discuss / approximate
- Zed option: `editor::ToggleSemanticHighlights`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: Semantic highlighting differs from disabling Tree-sitter syntax highlighting.
  Catalog-only candidates need version/context verification.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Semantic highlighting does not toggle all syntax/Treesitter highlighting.

Category: search.

## N0155

- Key: `<Space>s/`
- Mode: normal
- Purpose: Search History
- Status: Discuss / approximate
- Zed option: `search::PreviousHistoryQuery`; `search::NextHistoryQuery`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: History navigation within search UI replaces the picker.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Search history actions require search-input focus; no equivalent history
  picker verified.

Category: search.

## N0677

- Key: `R`
- Mode: visual
- Purpose: Treesitter Search
- Status: Discuss / approximate
- Zed option: `vim::SelectLargerSyntaxNode`
- Current candidates: `vim::ToggleReplace`; `vim::SubstituteLine`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: Syntax-node selection does not reproduce Flash's labeled tree targets.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Syntax selection does not reproduce incremental regex selection.

Category: search.

## N0679

- Key: `R`
- Mode: operator-pending
- Purpose: Treesitter Search
- Status: Discuss / approximate
- Zed option: `vim::SelectLargerSyntaxNode`
- Current candidates: `vim::ToggleReplace`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: Syntax-node selection does not reproduce Flash's labeled tree targets.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Syntax selection does not reproduce incremental regex selection.

Category: terminal.

## N0319

- Key: `<Space>fT`
- Mode: normal
- Purpose: Terminal (cwd)
- Status: Discuss / approximate
- Zed option: `terminal_panel::Toggle`
- Suggestion: Use the Zed project as the main search/file scope; leave cwd/git-only
  variants open until filtering requirements are clear.
- Caution: Panel visibility/focus and terminal working directory differ from Snacks
  terminal creation.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: A terminal-panel toggle does not guarantee the current file's working
  directory.

Category: text objects.

## N0714 / N0716 / N0718

- Key: `[i`
- Mode: operator-pending, visual, normal
- Purpose: jump to top edge of scope
- Status: Discuss / approximate
- Zed option: `vim::PreviousSectionStart`; `vim::NextSectionStart`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: Section/indentation boundaries do not guarantee the same Tree-sitter scope.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Section boundaries do not reproduce indentation-scope navigation.

Category: text objects.

## N0769 / N0771 / N0773

- Key: `]i`
- Mode: operator-pending, visual, normal
- Purpose: jump to bottom edge of scope
- Status: Discuss / approximate
- Zed option: `vim::PreviousSectionStart`; `vim::NextSectionStart`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: Section/indentation boundaries do not guarantee the same Tree-sitter scope.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Section boundaries do not reproduce indentation-scope navigation.

Category: text objects.

## N0821 / N0823

- Key: `an`
- Mode: operator-pending, visual
- Purpose: Around next textobject
- Status: Discuss / approximate
- Zed option: `vim::PushObject`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: No previous/next mini.ai object-search semantics verified; ordinary text
  objects are insufficient.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: No verified next-text-object equivalent; ordinary PushObject is not
  equivalent.

Category: text objects.

## N0844 / N0846 / N0848

- Key: `g]`
- Mode: operator-pending, visual, normal
- Purpose: Move to right "around"
- Status: Discuss / approximate
- Zed option: `vim::NextMethodStart`; `vim::PreviousMethodStart`
- Current candidates: `editor::GoToDiagnostic`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: mini.ai object-dependent edge motion is not a fixed method motion.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Method starts do not reproduce arbitrary current text-object edges.

Category: text objects.

## N0850 / N0852 / N0854

- Key: `g[`
- Mode: operator-pending, visual, normal
- Purpose: Move to left "around"
- Status: Discuss / approximate
- Zed option: `vim::NextMethodStart`; `vim::PreviousMethodStart`
- Current candidates: `editor::GoToPreviousDiagnostic`
- Suggestion: Try the Zed option above; leave this key unchanged until you accept the
  difference.
- Caution: mini.ai object-dependent edge motion is not a fixed method motion.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Method starts do not reproduce arbitrary current text-object edges.

Category: text objects.

## N0891

- Key: `gc`
- Mode: operator-pending
- Purpose: Comment textobject
- Status: Discuss / approximate
- Zed option: `vim::PushToggleComments`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: Check count, operator-pending behavior and comment-object selection against
  mini-comment.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Vim comment toggling is an operator, not a comment text object.

Category: motions.

## N0943

- Key: `s`
- Mode: operator-pending
- Purpose: Flash
- Status: Discuss / approximate
- Zed option: `vim::HelixJumpToWord`
- Suggestion: Try the nearest native Vim motion/object first; retain this as an open
  difference until language, count and operator behavior match.
- Caution: Zed word labels differ from Flash search and operator-pending support.
  Current custom s only covers normal/visual modes.
- Previous choice: suggestion
- Your choice: TODO
- Deferral: Jump labels move the cursor but do not apply the pending Vim operator.
  Normal/visual s remain bound.
