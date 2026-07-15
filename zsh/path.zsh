#
# PATH entries.
#
# Hardcoded /home/nkolesnikov prefixes from the original ~/.zshrc were replaced
# with $HOME — same result, but portable to another machine or user.
#

# Go toolchain binaries.
export PATH="$PATH:$HOME/go/bin"

# pipx shims, codebase-memory-mcp, lazydocker. The original ~/.zshrc exported
# this twice (once via pipx, once via the codebase-memory-mcp installer); the
# duplicate is dropped here — the resulting lookup order is unchanged.
export PATH="$PATH:$HOME/.local/bin"

export PATH="/usr/local/python3.10/bin:$PATH"

# opencode.
export PATH="$HOME/.opencode/bin:$PATH"

# LM Studio CLI (lms).
export PATH="$PATH:$HOME/.lmstudio/bin"

# bun. BUN_INSTALL is also read by bun itself, not just for PATH.
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
