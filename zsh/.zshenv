#
# ~/.zshenv — sourced by every zsh, interactive or not.
#
# Keep this file minimal: it runs for scripts and `zsh -c` too, not just for
# terminals. Anything only a human needs belongs in .zshrc.
#

# Rust toolchain (rustup/cargo). Guarded so a machine without Rust still starts
# a shell — the original was an unguarded `.` call.
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Machine-local secrets and per-machine overrides. Untracked by git; create it
# from zsh/zshenv.local.example. Sourced here rather than from .zshrc so that
# tokens are available to non-interactive shells and scripts as well.
[ -r "$HOME/.zshenv.local" ] && . "$HOME/.zshenv.local"
