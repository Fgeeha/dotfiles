#!/usr/bin/env bash
#
# install.sh — idempotent installer for these dotfiles.
#
# Symlinks the tracked configs into $HOME and installs the VSCode extensions
# listed in vscode/**/extensions.txt.
#
# Safety model:
#   * Existing real files are backed up to <file>.backup before being replaced,
#     and never silently overwritten. If a .backup already exists, it is kept
#     and the new one becomes .backup.1, .backup.2, ...
#   * Any replacement of existing content asks for confirmation first, unless
#     --yes is passed.
#   * A symlink already pointing at the right target is left alone, so re-runs
#     are no-ops. Nothing is ever deleted.
#
# Usage:
#   ./install.sh                 # everything, interactive
#   ./install.sh --yes           # everything, no prompts (for provisioning)
#   ./install.sh --dry-run       # print what would happen, change nothing
#   ./install.sh --shell-only      # only shell configs (zsh/bash/nano/warp/...)
#   ./install.sh --vscode-only     # only VSCode configs + extensions
#   ./install.sh --extensions-only # only VSCode extensions, no symlinking
#   ./install.sh --no-extensions   # skip the slow `code --install-extension` loop
#   ./install.sh --help
#

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ASSUME_YES=0
DRY_RUN=0
DO_SHELL=1
DO_VSCODE=1
DO_EXTENSIONS=1
DO_VSCODE_LINKS=1

# --- output helpers -----------------------------------------------------------

if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_INFO=$'\033[34m'; C_OK=$'\033[32m'
  C_WARN=$'\033[33m'; C_ERR=$'\033[31m'; C_DIM=$'\033[2m'
else
  C_RESET=''; C_INFO=''; C_OK=''; C_WARN=''; C_ERR=''; C_DIM=''
fi

info()  { printf '%s==>%s %s\n' "$C_INFO" "$C_RESET" "$*"; }
ok()    { printf '%s  ok%s %s\n' "$C_OK" "$C_RESET" "$*"; }
skip()  { printf '%s  --%s %s\n' "$C_DIM" "$C_RESET" "$*"; }
warn()  { printf '%s  !!%s %s\n' "$C_WARN" "$C_RESET" "$*" >&2; }
die()   { printf '%serror:%s %s\n' "$C_ERR" "$C_RESET" "$*" >&2; exit 1; }

usage() { sed -n '2,/^set -euo/p' "${BASH_SOURCE[0]}" | sed 's/^#\{1,2\} \{0,1\}//; $d'; }

# Ask before touching existing content. --yes answers yes; --dry-run answers no,
# since a dry run must not depend on the user being there.
confirm() {
  local prompt="$1"
  [ "$DRY_RUN" -eq 1 ] && return 0
  [ "$ASSUME_YES" -eq 1 ] && return 0
  local reply
  printf '%s  ?? %s [y/N] %s' "$C_WARN" "$prompt" "$C_RESET"
  read -r reply </dev/tty || return 1
  [[ "$reply" =~ ^[Yy]$ ]]
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '%s  would run:%s %s\n' "$C_DIM" "$C_RESET" "$*"
    return 0
  fi
  "$@"
}

# --- argument parsing ---------------------------------------------------------

while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes)        ASSUME_YES=1 ;;
    -n|--dry-run)    DRY_RUN=1 ;;
    --shell-only)    DO_VSCODE=0 ;;
    --vscode-only)   DO_SHELL=0 ;;
    --extensions-only) DO_SHELL=0; DO_VSCODE_LINKS=0 ;;
    --no-extensions) DO_EXTENSIONS=0 ;;
    -h|--help)       usage; exit 0 ;;
    *)               die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

# --- platform detection -------------------------------------------------------

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      die "unsupported OS: $(uname -s)" ;;
  esac
}

OS="$(detect_os)"

# VSCode stores its user config in a different place on each platform.
vscode_user_dir() {
  case "$OS" in
    macos) echo "$HOME/Library/Application Support/Code/User" ;;
    linux) echo "${XDG_CONFIG_HOME:-$HOME/.config}/Code/User" ;;
  esac
}

# --- linking primitives -------------------------------------------------------

# Move an existing path aside to <path>.backup, without clobbering older backups.
backup_path() {
  local target="$1" backup="${1}.backup" n=1
  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="${target}.backup.${n}"
    n=$((n + 1))
  done
  run mv -- "$target" "$backup"
  warn "backed up $(basename "$target") -> $(basename "$backup")"
}

# link <source-in-repo> <destination-in-home>
link() {
  local src="$1" dst="$2"

  [ -e "$src" ] || { warn "missing in repo, skipping: $src"; return 0; }

  # Already correct — the idempotent path.
  if [ -L "$dst" ] && [ "$(readlink -- "$dst")" = "$src" ]; then
    skip "$dst"
    return 0
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ]; then
      # A symlink pointing somewhere else: no user data at risk, just repoint it.
      confirm "repoint $dst (currently -> $(readlink -- "$dst"))?" || { skip "$dst (declined)"; return 0; }
      run rm -f -- "$dst"
    else
      confirm "replace $dst with a symlink? (a .backup copy is kept)" || { skip "$dst (declined)"; return 0; }
      backup_path "$dst"
    fi
  fi

  run mkdir -p -- "$(dirname "$dst")"
  run ln -sfn -- "$src" "$dst"
  ok "$dst -> $src"
}

# --- shell configs ------------------------------------------------------------

install_shell() {
  info "Shell configs"

  # ~/.zsh is the module directory that zsh/.zshrc sources from. Linking the
  # whole directory means new modules appear without re-running the installer.
  link "$DOTFILES/zsh"                  "$HOME/.zsh"
  link "$DOTFILES/zsh/.zshrc"           "$HOME/.zshrc"
  link "$DOTFILES/zsh/.zshenv"          "$HOME/.zshenv"
  link "$DOTFILES/zsh/.zprofile"        "$HOME/.zprofile"

  link "$DOTFILES/bash/.bashrc"         "$HOME/.bashrc"
  link "$DOTFILES/bash/.bash_profile"   "$HOME/.bash_profile"

  link "$DOTFILES/nano/.nanorc"         "$HOME/.nanorc"
  link "$DOTFILES/editorconfig/.editorconfig" "$HOME/.editorconfig"

  link "$DOTFILES/warp/themes"          "$HOME/.warp/themes"
  link "$DOTFILES/warp/workflows"       "$HOME/.warp/workflows"

  install_secrets_template
  install_omz_plugins
}

# Seed ~/.zshenv.local from the tracked template. Never overwrite it: it holds
# the only copy of the real tokens.
install_secrets_template() {
  local dst="$HOME/.zshenv.local"
  if [ -e "$dst" ]; then
    skip "$dst (exists — left untouched)"
    return 0
  fi
  run cp -- "$DOTFILES/zsh/zshenv.local.example" "$dst"
  run chmod 600 -- "$dst"
  ok "$dst created from template"
  warn "fill in ~/.zshenv.local — tokens are NOT in this repo"
}

# zsh-autosuggestions and zsh-syntax-highlighting are listed in zsh/plugins.zsh
# but are not bundled with oh-my-zsh; without them every shell prints a warning.
install_omz_plugins() {
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    warn "oh-my-zsh is not installed — zsh/plugins.zsh will fail until it is:"
    warn '  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    return 0
  fi

  command -v git >/dev/null 2>&1 || { warn "git not found, skipping oh-my-zsh plugins"; return 0; }

  local name url
  while read -r name url; do
    [ -n "$name" ] || continue
    if [ -d "$custom/plugins/$name" ]; then
      skip "oh-my-zsh plugin: $name"
    else
      run git clone --depth 1 -- "$url" "$custom/plugins/$name" >/dev/null 2>&1 \
        && ok "oh-my-zsh plugin: $name" \
        || warn "failed to clone $name from $url"
    fi
  done <<'PLUGINS'
zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
PLUGINS
}

# --- VSCode -------------------------------------------------------------------

install_vscode() {
  local user_dir; user_dir="$(vscode_user_dir)"
  info "VSCode ($OS: $user_dir)"

  if [ "$DO_VSCODE_LINKS" -eq 1 ]; then
    if [ ! -d "$user_dir" ] && [ "$DRY_RUN" -eq 0 ]; then
      warn "$user_dir does not exist — creating it (VSCode may not be installed yet)"
      run mkdir -p -- "$user_dir"
    fi

    link "$DOTFILES/vscode/settings.json"    "$user_dir/settings.json"
    link "$DOTFILES/vscode/keybindings.json" "$user_dir/keybindings.json"
    link "$DOTFILES/vscode/mcp.json"         "$user_dir/mcp.json"
    link "$DOTFILES/vscode/snippets"         "$user_dir/snippets"

    install_vscode_profiles "$user_dir"
  fi

  [ "$DO_EXTENSIONS" -eq 1 ] && install_vscode_extensions
}

# Profile directories are named after an opaque hash, not the profile name, and
# the hash differs per machine. storage.json holds the name -> directory map, so
# resolve through it rather than hardcoding.
resolve_profile_dir() {
  local user_dir="$1" name="$2"
  python3 - "$user_dir" "$name" <<'PY' 2>/dev/null || true
import json, os, sys
user_dir, want = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(os.path.join(user_dir, "globalStorage", "storage.json")))
except Exception:
    sys.exit(0)
for p in data.get("userDataProfiles", []):
    if p.get("name") == want:
        print(os.path.join(user_dir, "profiles", p["location"]))
        break
PY
}

install_vscode_profiles() {
  local user_dir="$1" pdir name target

  command -v python3 >/dev/null 2>&1 || { warn "python3 not found — skipping profile settings"; return 0; }

  for pdir in "$DOTFILES"/vscode/profiles/*/; do
    [ -d "$pdir" ] || continue
    pdir="${pdir%/}"                 # strip the glob's trailing slash
    name="$(basename "$pdir")"

    target="$(resolve_profile_dir "$user_dir" "$name")"
    if [ -z "$target" ]; then
      # The profile does not exist yet on this machine. Creating one from the
      # CLI is not supported, but `code --profile "$name" --install-extension`
      # below creates it, so this resolves itself on the second run.
      warn "VSCode profile \"$name\" not found — will be created by the extension step; re-run install.sh afterwards to link its settings"
      continue
    fi

    link "$pdir/settings.json"    "$target/settings.json"
    link "$pdir/keybindings.json" "$target/keybindings.json"
    link "$DOTFILES/vscode/mcp.json" "$target/mcp.json"
  done
}

# Read an extensions.txt: strip comments and blank lines.
read_extensions() { grep -vE '^\s*(#|$)' "$1" || true; }

install_extensions_into() {
  local list="$1" profile="${2:-}" ext installed target_desc
  local -a code_args

  [ -f "$list" ] || return 0

  if [ -n "$profile" ]; then
    code_args=(--profile "$profile")
    target_desc="profile \"$profile\""
  else
    code_args=()
    target_desc="default profile"
  fi

  # One `code --list-extensions` call up front, so we can skip what is present
  # instead of shelling out per extension.
  installed="$(code "${code_args[@]}" --list-extensions 2>/dev/null || true)"

  info "Extensions: $target_desc ($(read_extensions "$list" | wc -l | tr -d ' ') listed)"
  while read -r ext; do
    [ -n "$ext" ] || continue
    if printf '%s\n' "$installed" | grep -qixF -- "$ext"; then
      skip "$ext"
    else
      run code "${code_args[@]}" --install-extension "$ext" --force >/dev/null 2>&1 \
        && ok "$ext" \
        || warn "failed to install $ext"
    fi
  done < <(read_extensions "$list")
}

install_vscode_extensions() {
  if ! command -v code >/dev/null 2>&1; then
    warn "the 'code' CLI is not on PATH — skipping extensions"
    warn "in VSCode: Command Palette -> 'Shell Command: Install code command in PATH'"
    return 0
  fi

  install_extensions_into "$DOTFILES/vscode/extensions.txt"

  local pdir name
  for pdir in "$DOTFILES"/vscode/profiles/*/; do
    [ -d "$pdir" ] || continue
    pdir="${pdir%/}"
    name="$(basename "$pdir")"
    install_extensions_into "$pdir/extensions.txt" "$name"
  done
}

# --- main ---------------------------------------------------------------------

main() {
  [ "$DRY_RUN" -eq 1 ] && info "DRY RUN — nothing will be changed"
  info "dotfiles: $DOTFILES"

  [ "$DO_SHELL"  -eq 1 ] && install_shell
  [ "$DO_VSCODE" -eq 1 ] && install_vscode

  info "Done."
  if [ "$DO_SHELL" -eq 1 ]; then
    echo
    echo "Next:"
    echo "  1. Fill in your tokens:  \$EDITOR ~/.zshenv.local"
    echo "  2. Reload the shell:     exec zsh"
    echo "  3. Default shell:        chsh -s \$(which zsh)"
  fi
}

main "$@"
