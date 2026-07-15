#
# oh-my-zsh: theme and plugins.
#
# ZSH, ZSH_THEME and plugins must all be set before oh-my-zsh.sh is sourced —
# it reads them at load time.
#
# zsh-autosuggestions and zsh-syntax-highlighting are not bundled with
# oh-my-zsh; they are cloned into $ZSH_CUSTOM/plugins/ (install.sh does this).
#

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnosterzak"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  python
  poetry
)

source "$ZSH/oh-my-zsh.sh"
