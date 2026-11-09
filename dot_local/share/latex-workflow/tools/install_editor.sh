#!/bin/bash
# Install/update the normal editor without reinstalling TeX/Python packages.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
editor="${LATEX_WORKFLOW_EDITOR:-code}"
mkdir -p "$root/cache"
# Configure both the default profile and the established Desktop profile.
install_extensions() {
    profile_args=("$@")
    while IFS= read -r extension; do
        [ -n "$extension" ] || continue
        "$editor" "${profile_args[@]}" --install-extension "$extension"
    done < "$root/extensions.txt"
    # Install Helix successfully before removing conflicting modal keymaps.
    for conflict in vscodevim.vim gregoire.dance gregoire.dance-helix; do
        if "$editor" "${profile_args[@]}" --list-extensions | grep -Fxiq "$conflict"; then
            "$editor" "${profile_args[@]}" --uninstall-extension "$conflict"
        fi
    done
    "$root/.venv/bin/python" "$root/tools/package_visual_extension.py"
    "$editor" "${profile_args[@]}" --install-extension "$root/cache/math-source-preview.vsix" --force
}
install_extensions
install_extensions --profile Desktop
"$root/.venv/bin/python" "$root/tools/workflow.py" editor-config
echo 'LaTeX is integrated into normal VS Code. Run Developer: Reload Window.'
