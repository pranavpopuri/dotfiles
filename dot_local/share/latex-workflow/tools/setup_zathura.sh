#!/bin/bash
# Homebrew's macOS Zathura port needs SyncTeX and one PDF plugin.
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
brew tap homebrew-zathura/zathura
# Trust the specific viewer and its required tap dependencies, not the whole tap.
if brew help trust >/dev/null 2>&1; then
    for formula in zathura synctex girara zathura-pdf-poppler; do
        brew trust --formula "homebrew-zathura/zathura/$formula"
    done
fi
brew install homebrew-zathura/zathura/zathura --with-synctex
brew install homebrew-zathura/zathura/zathura-pdf-poppler
viewer_prefix="$(brew --prefix homebrew-zathura/zathura/zathura)"
plugin_prefix="$(brew --prefix homebrew-zathura/zathura/zathura-pdf-poppler)"
mkdir -p "$viewer_prefix/lib/zathura"
ln -sfn "$plugin_prefix/libpdf-poppler.dylib" "$viewer_prefix/lib/zathura/libpdf-poppler.dylib"
test -f "$viewer_prefix/lib/zathura/libpdf-poppler.dylib"
if ! /usr/bin/otool -L "$(command -v zathura)" | rg -q 'libsynctex'; then
    echo 'Warning: the Homebrew build omitted SyncTeX. PDF viewing works; source/PDF navigation is unavailable.' >&2
fi
echo 'Zathura and its PDF plugin are ready.'
