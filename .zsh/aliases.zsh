# Alias
# ---
#
alias k="kubectl"
alias h="helm"
alias c="clear"
alias cat='bat'
alias pip="pip3"
alias py="python3"
alias python="python3"
# alias code="open -a 'Visual Studio Code'"

alias gprj="cd $HOME/Projects"

alias grep='grep --color'


# Sorts directories in top, colors, and prints `/` at directories:
alias ls='gls --color -h --group-directories-first -F'

# Use syntax highlight for `cat`:
alias cat='bat --paging never --decorations never --plain'

# Copy public key to clipboard:
alias pubkey="cat ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
