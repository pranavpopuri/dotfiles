#!/bin/bash
# Rebuild machine-specific environments from the chezmoi-managed toolkit source.
set -euo pipefail
if [ "$(uname -s)" != Darwin ]; then
    echo 'This installer is macOS-only; Linux configuration is unchanged.'
    exit 0
fi
root="$(cd "$(dirname "$0")" && pwd)"
export PATH="$HOME/Library/TinyTeX/bin/universal-darwin:/Library/TeX/texbin:/opt/homebrew/bin:/usr/local/bin:$PATH"
mkdir -p "$root/cache"
if ! command -v brew >/dev/null; then
    echo 'Install Homebrew first, then rerun latex-workflow setup.' >&2
    exit 1
fi
if ! brew bundle check --file="$root/config/Brewfile" >/dev/null 2>&1; then
    brew bundle --file="$root/config/Brewfile"
fi
if ! command -v tlmgr >/dev/null; then
    curl -fL https://tinytex.yihui.org/install-bin-unix.sh -o "$root/cache/install-tinytex.sh"
    (cd "$root/cache" && sh install-tinytex.sh)
fi
if ! command -v latexmk >/dev/null; then tlmgr install latexmk; fi
if [ ! -x "$root/.venv/bin/python" ]; then python3 -m venv "$root/.venv"; fi
requirements_hash="$(shasum -a 256 "$root/tools/requirements-math.txt" | cut -d ' ' -f 1)"
if [ "$(cat "$root/cache/python-requirements.sha256" 2>/dev/null || true)" != "$requirements_hash" ] || ! "$root/.venv/bin/python" -c 'import sympy,matplotlib,pygments' 2>/dev/null; then
    "$root/.venv/bin/python" -m pip install -r "$root/tools/requirements-math.txt"
    echo "$requirements_hash" > "$root/cache/python-requirements.sha256"
fi
export TEXMFHOME="$root/texmf"
mkdir -p "$TEXMFHOME"
if [ ! -f "$TEXMFHOME/tlpkg/texlive.tlpdb" ]; then
    tlmgr --usermode --usertree "$TEXMFHOME" init-usertree
fi
tlmgr --usermode --usertree "$TEXMFHOME" install \
    fvextra fancyvrb upquote lineno xstring pgfopts pgf newfloat currfile \
    kvoptions ltxcmds kvsetkeys filehook etoolbox xcolor pgfplots \
    import xifthen ifmtarg pdfpages transparent siunitx eso-pic grfext \
    pdfcol auxhook infwarerr epstopdf-pkg translations pdfescape
system_texmf="$(kpsewhich -var-value=TEXMFROOT)/texmf-dist"
if [ ! -f "$system_texmf/scripts/pythontex/pythontex.py" ]; then
    # PythonTeX is non-relocatable; fresh user-owned TinyTeX installations can
    # install it normally. Existing installed copies are only read below.
    tlmgr install pythontex
fi
"$root/.venv/bin/python" "$root/tools/copy_pythontex.py" "$system_texmf"
mktexlsr "$TEXMFHOME"
# Add the LaTeX tools to the existing VSCodium installation.
bash "$root/tools/install_editor.sh"
"$root/.venv/bin/python" "$root/tools/workflow.py" doctor
# A fresh temporary note project verifies that builds need no testing-repo files.
check_project="$(mktemp -d "${TMPDIR:-/tmp}/latex-workflow-check.XXXXXX")"
trap 'rm -rf "$check_project"' EXIT
cp "$root/examples/workflow-example.tex" "$check_project/"
cp "$root/examples/pythontex-example.tex" "$check_project/"
cp "$root/examples/plots-example.tex" "$check_project/"
cp "$root/examples/figures-example.tex" "$check_project/"
mkdir -p "$check_project/figures"
cp "$root/examples/figures/triangle.svg" "$check_project/figures/"
"$root/.venv/bin/python" "$root/tools/workflow.py" build "$check_project/workflow-example.tex"
"$root/.venv/bin/python" "$root/tools/workflow.py" build --pythontex "$check_project/pythontex-example.tex"
"$root/.venv/bin/python" "$root/tools/workflow.py" plot --project "$check_project"
"$root/.venv/bin/python" "$root/tools/workflow.py" build "$check_project/plots-example.tex"
"$root/.venv/bin/python" "$root/tools/workflow.py" figure export triangle --project "$check_project"
"$root/.venv/bin/python" "$root/tools/workflow.py" build "$check_project/figures-example.tex"
echo 'LaTeX toolkit ready. Use: latex-workflow open /path/to/notes'
