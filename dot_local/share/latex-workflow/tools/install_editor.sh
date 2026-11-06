#!/bin/bash
# Install/update the normal editor without reinstalling TeX/Python packages.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
editor="${LATEX_WORKFLOW_EDITOR:-codium}"
mkdir -p "$root/cache"
while IFS= read -r extension; do
    [ -n "$extension" ] || continue
    "$editor" --install-extension "$extension"
done < "$root/extensions.txt"
# Install Helix successfully before removing the conflicting Vim keymap.
if "$editor" --list-extensions | grep -Fxiq vscodevim.vim; then
    "$editor" --uninstall-extension vscodevim.vim
fi
"$root/.venv/bin/python" "$root/tools/package_visual_extension.py"
"$editor" --install-extension "$root/cache/math-source-preview.vsix" --force
"$root/.venv/bin/python" "$root/tools/workflow.py" editor-config
echo 'LaTeX is integrated into normal VSCodium. Run Developer: Reload Window.'
