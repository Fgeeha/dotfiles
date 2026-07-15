#
# Shell greeting: a random Pokemon colorscript used as the fastfetch logo.
# https://gitlab.com/phoneybadger/pokemon-colorscripts
#
# The guard is the one deliberate change from the original ~/.zshrc: without it,
# a machine that has not installed these two tools yet opens every shell with a
# "command not found" pair. With both installed the output is identical.
#

if command -v pokemon-colorscripts >/dev/null 2>&1 && command -v fastfetch >/dev/null 2>&1; then
  pokemon-colorscripts --no-title -s -r \
    | fastfetch -c "$HOME/.config/fastfetch/config-pokemon.jsonc" \
        --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
fi

# Alternative greeting, without the colorscript — swap for the block above:
# fastfetch -c "$HOME/.config/fastfetch/config-compact.jsonc"
