#
# ~/.zshrc — interactive shell configuration.
#
# Symlinked from the dotfiles repo by install.sh. This file only wires modules
# together; the actual configuration lives in ~/.zsh/*.zsh (also symlinked).
#
# Load order is deliberate:
#   path      PATH must be complete before anything resolves a binary
#   exports   plain environment variables
#   plugins   oh-my-zsh: theme + plugin list, then sources oh-my-zsh.sh
#   aliases   may shadow binaries resolved above, so it comes after them
#   history   setopt calls
#   functions definitions only, no side effects at load time
#   tools     nvm / bun / completions — slow, so kept late
#   greeting  purely visual, must run last
#
# Secrets are NOT here. They live in ~/.zshenv.local, which is untracked and
# sourced from ~/.zshenv. See zsh/zshenv.local.example for the template.
#

ZSH_MODULES="${HOME}/.zsh"

for _zsh_module in path exports plugins aliases history functions tools greeting; do
  [[ -r "${ZSH_MODULES}/${_zsh_module}.zsh" ]] && source "${ZSH_MODULES}/${_zsh_module}.zsh"
done
unset _zsh_module
