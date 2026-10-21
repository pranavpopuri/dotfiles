#!/bin/bash
# Install core CLI tools into ~/bin on Linux — no root required.
#
# Uses eget (https://github.com/zyedidia/eget) to fetch the right prebuilt
# binary for this machine's OS/arch from each project's GitHub releases, so
# there are no hardcoded versions, architecture strings, or download URLs to
# maintain. Everything stays inside $HOME and is trivially removable.
#
# To pin a tool for reproducibility, add `--tag vX.Y.Z` to its line.
# If you hit GitHub API rate limits, export GITHUB_TOKEN before running.
set -e
mkdir -p "$HOME/bin"

# eget's --asset filter is a plain substring match — a leading ^ excludes
# instead of including — and the filters run as a chain: each one narrows the
# candidate list, and the first one leaving exactly one asset wins. If a
# filter still leaves several, eget falls back to matching OS/arch, and if
# that is ambiguous too it prompts — which hangs a non-interactive run. So
# every tool below pins its asset explicitly for the detected architecture.
case "$(uname -m)" in
	x86_64|amd64)	ARCH_GNU=x86_64; ARCH_SHORT=x64; FNM_ASSET=fnm-linux.zip ;;
	aarch64|arm64)	ARCH_GNU=aarch64; ARCH_SHORT=arm64; FNM_ASSET=fnm-arm64.zip ;;
	*) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# Bootstrap eget itself (its installer detects platform automatically).
if [ ! -x "$HOME/bin/eget" ]; then
	echo "Installing eget..."
	cd /tmp
	curl -fsSL https://zyedidia.github.io/eget.sh | sh
	mv eget "$HOME/bin/"
fi

EGET="$HOME/bin/eget"

# ripgrep ships both a musl and a gnu build for aarch64, which eget's arch
# matcher cannot tell apart — pin the asset or the run prompts and hangs.
"$EGET" BurntSushi/ripgrep --to "$HOME/bin" --asset "$ARCH_GNU-unknown-linux-musl.tar.gz" --asset ^sha256
"$EGET" sharkdp/fd         --to "$HOME/bin" --asset musl --asset ^deb
"$EGET" eza-community/eza  --to "$HOME/bin" --asset gnu --asset tar.gz --asset ^no_libgit
"$EGET" ajeetdsouza/zoxide --to "$HOME/bin"
"$EGET" junegunn/fzf       --to "$HOME/bin"
"$EGET" charmbracelet/glow --to "$HOME/bin" --asset tar.gz --asset ^sbom
"$EGET" sxyazi/yazi        --to "$HOME/bin" --asset musl --asset ^deb --file yazi
"$EGET" sxyazi/yazi        --to "$HOME/bin" --asset musl --asset ^deb --file ya

# Shell tooling the dotfiles reference: starship (the prompt, see
# ~/.config/starship.toml), fnm (per-directory node versions), tirith
# (shellrc-common) and opencode (the `oc` alias).
"$EGET" starship/starship --to "$HOME/bin" --asset "$ARCH_GNU-unknown-linux-musl.tar.gz" --asset ^sha256
"$EGET" Schniz/fnm        --to "$HOME/bin" --asset "$FNM_ASSET"
"$EGET" sheeki03/tirith   --to "$HOME/bin" --asset "$ARCH_GNU-unknown-linux-gnu.tar.gz"
"$EGET" sst/opencode      --to "$HOME/bin" --asset "opencode-linux-$ARCH_SHORT.tar.gz"

# Node itself: fnm pulls the requested release straight from nodejs.org, so
# the version stays unpinned here just like everything else above.
echo "Installing Node.js (LTS)..."
export FNM_DIR="${FNM_DIR:-$HOME/.local/share/fnm}"
"$HOME/bin/fnm" install --lts --use
eval "$("$HOME/bin/fnm" env --shell bash)"

# wikimap toolchain: markmap renders map.md into an interactive tree,
# markserv serves the wiki so map nodes open rendered markdown.
for pkg in markmap-cli markserv; do
	npm ls -g --depth=0 "$pkg" >/dev/null 2>&1 || npm install -g "$pkg"
done

# helix ships the hx binary plus a runtime/ directory it requires; eget only
# extracts single binaries, so download the tarball and place both ourselves.
# (Needs glibc + xz, both present on standard distros; not Alpine.)
echo "Installing helix..."
hxtmp=$(mktemp -d)
"$EGET" helix-editor/helix --to "$hxtmp" --asset .tar --download-only
tar -xf "$hxtmp"/helix-*-linux.tar.* -C "$hxtmp"
hxdir=$(find "$hxtmp" -maxdepth 1 -type d -name 'helix-*-linux')
cp "$hxdir/hx" "$HOME/bin/" && chmod +x "$HOME/bin/hx"

# The runtime holds the tree-sitter grammars and the query files that
# ~/.config/helix/runtime/queries/ is managed by chezmoi. Replace the
# runtime wholesale, but keep our query overrides — the upstream tarball
# ships its own copies of queries/{cpp,cuda,mips} and would clobber them.
queries_backup=$(mktemp -d)
if [ -d "$HOME/.config/helix/runtime/queries" ]; then
	cp -r "$HOME/.config/helix/runtime/queries/." "$queries_backup/"
fi
mkdir -p "$HOME/.config/helix"
rm -rf "$HOME/.config/helix/runtime"
cp -r "$hxdir/runtime" "$HOME/.config/helix/runtime"
mkdir -p "$HOME/.config/helix/runtime/queries"
cp -r "$queries_backup/." "$HOME/.config/helix/runtime/queries/"
rm -rf "$queries_backup" "$hxtmp"

# Helix builds tree-sitter grammars on demand (the MIPS one included), which
# needs git to fetch the grammar and a C compiler to build it. Both are
# usually already there on a dev box, but the install cannot do it itself
# without root.
if ! command -v git >/dev/null 2>&1 || ! command -v cc >/dev/null 2>&1; then
	echo "Note: git and a C compiler are needed to build Helix's tree-sitter" >&2
	echo "      grammars (e.g. for MIPS). Install them, then run" >&2
	echo "      ':grammar fetch' and ':grammar build' inside Helix." >&2
fi

# Nerd Font for icon glyphs (eza --icons, etc.) when using a GUI terminal
# *inside* the VM (e.g. UTM Ubuntu desktop). Harmless headless or over SSH,
# where the client terminal's own font does the rendering. After install,
# select "FiraCode Nerd Font" in your VM terminal's font settings.
echo "Installing FiraCode Nerd Font..."
fontdir="$HOME/.local/share/fonts"
mkdir -p "$fontdir"
fonttmp=$(mktemp -d)
"$EGET" ryanoasis/nerd-fonts --to "$fonttmp" --asset FiraCode.tar.xz --download-only
tar -xf "$fonttmp"/FiraCode.tar.* -C "$fontdir"
command -v fc-cache >/dev/null && fc-cache -f "$fontdir" >/dev/null 2>&1 || true
rm -rf "$fonttmp"

echo "Done! Tools installed to ~/bin"
