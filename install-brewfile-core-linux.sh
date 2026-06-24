#!/bin/bash
set -e
mkdir -p ~/bin
cd /tmp

# Pick release-asset identifiers per CPU architecture.
case "$(uname -m)" in
	x86_64|amd64)
		RG_TRIPLE=x86_64-unknown-linux-musl
		FD_TRIPLE=x86_64-unknown-linux-musl
		EZA_FILE=eza_x86_64-unknown-linux-musl.tar.gz
		ZOXIDE_TRIPLE=x86_64-unknown-linux-musl
		FZF_ARCH=linux_amd64
		GLOW_ARCH=x86_64
		YAZI_TRIPLE=x86_64-unknown-linux-musl
		;;
	aarch64|arm64)
		RG_TRIPLE=aarch64-unknown-linux-gnu
		FD_TRIPLE=aarch64-unknown-linux-musl
		EZA_FILE=eza_aarch64-unknown-linux-gnu.tar.gz
		ZOXIDE_TRIPLE=aarch64-unknown-linux-musl
		FZF_ARCH=linux_arm64
		GLOW_ARCH=arm64
		YAZI_TRIPLE=aarch64-unknown-linux-musl
		;;
	*)
		echo "Unsupported architecture: $(uname -m). Add its release assets to this script." >&2
		exit 1
		;;
esac

echo "Installing ripgrep..."
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-${RG_TRIPLE}.tar.gz
tar xzf ripgrep-14.1.1-${RG_TRIPLE}.tar.gz
cp ripgrep-14.1.1-${RG_TRIPLE}/rg ~/bin/

echo "Installing fd..."
curl -LO https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-${FD_TRIPLE}.tar.gz
tar xzf fd-v10.2.0-${FD_TRIPLE}.tar.gz
cp fd-v10.2.0-${FD_TRIPLE}/fd ~/bin/

echo "Installing eza..."
curl -LO https://github.com/eza-community/eza/releases/download/v0.23.0/${EZA_FILE}
tar xzf ${EZA_FILE}
cp eza ~/bin/

echo "Installing zoxide..."
curl -LO https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.9/zoxide-0.9.9-${ZOXIDE_TRIPLE}.tar.gz
tar xzf zoxide-0.9.9-${ZOXIDE_TRIPLE}.tar.gz
cp zoxide ~/bin/

echo "Installing fzf..."
curl -LO https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-${FZF_ARCH}.tar.gz
tar xzf fzf-0.62.0-${FZF_ARCH}.tar.gz
cp fzf ~/bin/

echo "Installing glow..."
curl -LO https://github.com/charmbracelet/glow/releases/download/v2.1.0/glow_2.1.0_Linux_${GLOW_ARCH}.tar.gz
tar xzf glow_2.1.0_Linux_${GLOW_ARCH}.tar.gz
cp glow_2.1.0_Linux_${GLOW_ARCH}/glow ~/bin/

echo "Installing yazi..."
curl -LO https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-${YAZI_TRIPLE}.zip
unzip -o yazi-${YAZI_TRIPLE}.zip
cp yazi-${YAZI_TRIPLE}/yazi ~/bin/
cp yazi-${YAZI_TRIPLE}/ya ~/bin/

chmod +x ~/bin/rg ~/bin/fd ~/bin/eza ~/bin/zoxide ~/bin/fzf ~/bin/glow ~/bin/yazi ~/bin/ya

echo "Cleaning up..."
cd ~
rm -rf /tmp/ripgrep* /tmp/fd-* /tmp/eza* /tmp/zoxide* /tmp/fzf* /tmp/glow* /tmp/yazi*

echo "Done! All tools installed to ~/bin"
