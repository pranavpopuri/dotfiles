# Automatic LaTeX PDF preview

Edit notes in VS Code or VSCodium using the existing Helix bindings and snippets.
The editor saves with no configured delay; file changes trigger the toolkit
latexmk recipe without an added build interval. The first successful build opens Zathura. Keep it beside the
editor: subsequent successful builds update the same window automatically.

Ctrl+L b builds manually, Ctrl+L v opens the PDF, and Ctrl+L s jumps from the
source to the PDF. Ctrl+click in Zathura navigates back through SyncTeX.
Diagnostics and build output remain available; error notifications are disabled
so incomplete equations do not interrupt typing. Automatic builds do not execute
the PythonTeX recipe.

The preview helper keeps one window per PDF while it is running. Closing that
window releases its lock; a subsequent successful build opens it again. Logs
are in ~/.local/share/latex-workflow/cache/pdf-preview.

Document compilation still takes time and grows with document complexity. Keep
the current lecture in its own document when fast updates matter. Existing
project or profile settings can override user settings.

Chezmoi tracks the shared settings template, build/preview helpers, Zathura
preferences, Homebrew dependencies and setup hook. VS Code user settings are
merged by the toolkit's editor-config command when that editor is installed;
VSCodium also has its existing chezmoi user-settings template.


Builds use a stable snapshot of the main source file, so typing does not keep
restarting latexmk. Failed builds preserve the last successful PDF. Completed
PDFs replace the displayed file atomically. Included files remain live inputs.
The built-in PDF viewer also works with this pipeline: its fade transition and
extra PDF polling wait are disabled. Generated .latex-build folders are excluded
from the editor's filesystem watcher.

Math Source Preview displays inactive equations inside the source editor and
adds a companion rendering beside the equation being edited. Unchanged previews
survive edits elsewhere. Tall equations can overlap because decorations cannot
reserve extra line height; hover gives a separate larger preview.

The current Homebrew Zathura may compile without SyncTeX because of its packaged
dependency version. The launcher detects that and opens PDFs without navigation.
Explicit View PDF requests foreground the external viewer; automatic builds do
not request focus. Runtime caches and installed dependencies are not committed.
