#!/bin/bash
# Install/update the dedicated editor without reinstalling TeX/Python packages.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
editor="${LATEX_WORKFLOW_EDITOR:-codium}"
editor_state="$HOME/.local/state/latex-workflow/vscodium"
mkdir -p "$root/extensions" "$root/cache"
while IFS= read -r extension; do
    [ -n "$extension" ] || continue
    "$editor" --user-data-dir "$editor_state" --extensions-dir "$root/extensions" --install-extension "$extension"
done < "$root/extensions.txt"
# Install Helix successfully before removing the conflicting Vim keymap.
if "$editor" --user-data-dir "$editor_state" --extensions-dir "$root/extensions" --list-extensions | grep -Fxiq vscodevim.vim; then
    "$editor" --user-data-dir "$editor_state" --extensions-dir "$root/extensions" --uninstall-extension vscodevim.vim
fi
"$root/.venv/bin/python" "$root/tools/package_visual_extension.py"
"$editor" --user-data-dir "$editor_state" --extensions-dir "$root/extensions" --install-extension "$root/cache/math-source-preview.vsix" --force
"$root/.venv/bin/python" "$root/tools/workflow.py" editor-links
echo 'Helix math editor ready. Close its existing windows and reopen with latex-workflow open PROJECT.'
