#
# ~/.zprofile — sourced once per login shell, before .zshrc.
#

# Autostart Hyprland on the first TTY. Left commented, as in the original.
#if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
#       Hyprland
#fi

# pipx (added 2025-10-30). Also set in zsh/path.zsh — kept here because login
# shells that never source .zshrc still need it.
export PATH="$PATH:$HOME/.local/bin"
