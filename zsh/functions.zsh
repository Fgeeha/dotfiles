#
# Shell functions.
#
# Definitions only — nothing here runs at shell startup, so this module is safe
# to load unconditionally. Both functions were carried over from the previous
# layout of this repo (.zsh/functions.zsh and .zsh/wsl2fix.zsh); the live
# ~/.zshrc never sourced them, so they are new to the shell but inert until
# called by name.
#

# Print the 256-colour palette as swatches — useful when picking theme colours.
function colormap() {
  for i in {0..255}; do
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
  done
}

# Work around the WSL2 interop error that intermittently breaks the VSCode
# terminal: find the interop socket of an ancestor process and re-point
# WSL_INTEROP at it. No effect outside WSL2.
function fix_wsl2_interop() {
  for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
    if [[ -e "/run/WSL/${i}_interop" ]]; then
      export WSL_INTEROP=/run/WSL/${i}_interop
    fi
  done
}
