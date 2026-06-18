#!/bin/bash
set -e
mkdir -p ~/bin
cd /tmp

echo "Installing ripgrep..."
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
tar xzf ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
cp ripgrep-14.1.1-x86_64-unknown-linux-musl/rg ~/bin/

echo "Installing fd..."
curl -LO https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-musl.tar.gz
tar xzf fd-v10.2.0-x86_64-unknown-linux-musl.tar.gz
cp fd-v10.2.0-x86_64-unknown-linux-musl/fd ~/bin/

echo "Installing eza..."
curl -LO https://github.com/eza-community/eza/releases/download/v0.23.0/eza_x86_64-unknown-linux-musl.tar.gz
tar xzf eza_x86_64-unknown-linux-musl.tar.gz
cp eza ~/bin/

echo "Installing zoxide..."
curl -LO https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.9/zoxide-0.9.9-x86_64-unknown-linux-musl.tar.gz
tar xzf zoxide-0.9.9-x86_64-unknown-linux-musl.tar.gz
cp zoxide ~/bin/

echo "Installing fzf..."
curl -LO https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz
tar xzf fzf-0.62.0-linux_amd64.tar.gz
cp fzf ~/bin/

echo "Installing glow..."
curl -LO https://github.com/charmbracelet/glow/releases/download/v2.1.0/glow_Linux_x86_64.tar.gz
tar xzf glow_Linux_x86_64.tar.gz
cp glow ~/bin/

echo "Installing yazi..."
curl -LO https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-musl.zip
unzip -o yazi-x86_64-unknown-linux-musl.zip
cp yazi-x86_64-unknown-linux-musl/yazi ~/bin/
cp yazi-x86_64-unknown-linux-musl/ya ~/bin/

echo "Cleaning up..."
cd ~
rm -rf /tmp/ripgrep* /tmp/fd-* /tmp/eza* /tmp/zoxide* /tmp/fzf* /tmp/glow* /tmp/yazi*

echo "Done! All tools installed to ~/bin"
