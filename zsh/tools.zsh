#
# Version managers and shell completions.
#
# These are the slowest part of shell startup, so they load near the end.
#

# nvm.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# bun completions. BUN_INSTALL and the PATH entry are set in path.zsh.
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
