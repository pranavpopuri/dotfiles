eval "$(tirith init)"

eval $(thefuck --alias --enable-experimental-instant-mode)

eval "$(zoxide init zsh)"

source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
source "$(brew --prefix)/opt/fzf/shell/completion.zsh"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

alias ls="eza --icons"
alias glow="glow --width 0"

alias dotfiles-sync="brew bundle dump --file=~/Documents/GitHub/dotfiles/Brewfile --force && system_profiler SPApplicationsDataType > ~/Documents/GitHub/dotfiles/apps_backup.txt"
