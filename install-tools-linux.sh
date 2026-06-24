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

# Bootstrap eget itself (its installer detects platform automatically).
if [ ! -x "$HOME/bin/eget" ]; then
	echo "Installing eget..."
	cd /tmp
	curl -fsSL https://zyedidia.github.io/eget.sh | sh
	mv eget "$HOME/bin/"
fi

EGET="$HOME/bin/eget"

# The --asset filters keep selection unambiguous; without them eget would
# prompt to choose between musl/gnu/.deb/etc. and a non-interactive run would
# hang. Verified non-interactive on x86_64 and aarch64.
"$EGET" BurntSushi/ripgrep --to "$HOME/bin"
"$EGET" sharkdp/fd         --to "$HOME/bin" --asset musl --asset ^deb
"$EGET" eza-community/eza  --to "$HOME/bin" --asset gnu --asset tar.gz --asset ^no_libgit
"$EGET" ajeetdsouza/zoxide --to "$HOME/bin"
"$EGET" junegunn/fzf       --to "$HOME/bin"
"$EGET" charmbracelet/glow --to "$HOME/bin" --asset tar.gz --asset ^sbom
"$EGET" sxyazi/yazi        --to "$HOME/bin" --asset musl --asset ^deb --file yazi
"$EGET" sxyazi/yazi        --to "$HOME/bin" --asset musl --asset ^deb --file ya

# helix ships the hx binary plus a runtime/ directory it requires; eget only
# extracts single binaries, so download the tarball and place both ourselves.
# (Needs glibc + xz, both present on standard distros; not Alpine.)
echo "Installing helix..."
hxtmp=$(mktemp -d)
"$EGET" helix-editor/helix --to "$hxtmp" --asset .tar --download-only
tar -xf "$hxtmp"/helix-*-linux.tar.* -C "$hxtmp"
hxdir=$(find "$hxtmp" -maxdepth 1 -type d -name 'helix-*-linux')
cp "$hxdir/hx" "$HOME/bin/" && chmod +x "$HOME/bin/hx"
mkdir -p "$HOME/.config/helix"
rm -rf "$HOME/.config/helix/runtime"
cp -r "$hxdir/runtime" "$HOME/.config/helix/runtime"
rm -rf "$hxtmp"

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
