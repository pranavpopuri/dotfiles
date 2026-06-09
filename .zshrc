# Added by Antigravity
export PATH="/Users/ppopuri/.antigravity/antigravity/bin:$PATH"

# Created by `pipx` on 2025-12-11 01:07:43
export PATH="$PATH:/Users/ppopuri/.local/bin"

# Created by `pipx` on 2025-12-11 01:07:43
export PATH="$PATH:/Users/ppopuri/Library/Python/3.9/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.local/bin:$PATH"

eval "$(tirith init)"

eval $(thefuck --alias --enable-experimental-instant-mode)

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/ppopuri/.lmstudio/bin"
# End of LM Studio CLI section



eval "$(zoxide init zsh)"

alias dotfiles-sync="brew bundle dump --file=~/Documents/GitHub/dotfiles/Brewfile --force && system_profiler SPApplicationsDataType > ~/Documents/GitHub/dotfiles/apps_backup.txt"
