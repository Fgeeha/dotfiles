#
# History behaviour.
#

# Append each command as it is entered rather than at shell exit, and share the
# history file live between concurrent shells.
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Use fcntl() locking on the history file — safer with SHARE_HISTORY above.
setopt HIST_FCNTL_LOCK

# NOTE: this is currently a no-op and is kept only to match the original config.
# oh-my-zsh reads HIST_STAMPS while lib/history.zsh loads, which already
# happened in plugins.zsh. To actually get dated `history` output, this line has
# to move into plugins.zsh *above* the `source "$ZSH/oh-my-zsh.sh"` call.
HIST_STAMPS="yyyy-mm-dd"
