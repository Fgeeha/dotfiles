# dotfiles

Personal configuration for zsh, VSCode and a few smaller tools, kept in one
place and installed with symlinks. Built from an Ubuntu 25.10 machine; the
installer also handles macOS paths.

Structured after [sobolevn/dotfiles](https://github.com/sobolevn/dotfiles):
one directory per tool, a single idempotent `install.sh`, a `Makefile` in front
of it.

```bash
git clone git@github.com:Fgeeha/dotfiles.git ~/Project/dotfiles
cd ~/Project/dotfiles
make dry-run              # see what would change — touches nothing
make install              # symlink configs + install VSCode extensions
$EDITOR ~/.zshenv.local   # add your tokens (see "Secrets" below)
exec zsh
```

## Layout

| Path | Links to | What it is |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | Loader only — sources the modules below, in order |
| `zsh/.zshenv` | `~/.zshenv` | Every shell: cargo env, `~/.zshenv.local` |
| `zsh/.zprofile` | `~/.zprofile` | Login shells: pipx PATH, Hyprland autostart (commented) |
| `zsh/` | `~/.zsh` | The module directory itself |
| `vscode/` | see below | Settings, keybindings, MCP, snippets, extension lists |
| `bash/` | `~/.bashrc`, `~/.bash_profile` | Fallback shell |
| `nano/` | `~/.nanorc` | nano editor |
| `warp/` | `~/.warp/{themes,workflows}` | Warp terminal |
| `editorconfig/` | `~/.editorconfig` | Global EditorConfig |
| `legacy/` | *(not linked)* | Superseded configs, kept for reference |

### zsh modules

`zsh/.zshrc` sources these by name, in this order. The order is load-bearing:
PATH must be complete before anything resolves a binary, aliases must come after
the binaries they shadow, and oh-my-zsh reads its variables at source time.

| Module | Contents |
|---|---|
| `path.zsh` | Go, pipx/`~/.local/bin`, python3.10, opencode, LM Studio, bun |
| `exports.zsh` | `DOCKER_BUILDKIT`, `COMPOSE_DOCKER_CLI_BUILD`, `KAGGLE_USERNAME`, `OLLAMA_API_KEY` |
| `plugins.zsh` | oh-my-zsh: `agnosterzak` theme; `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `python`, `poetry` |
| `aliases.zsh` | `lsd` wrappers (`ls`/`l`/`la`/`lla`/`lt`), `clip`, `lazydocker` |
| `history.zsh` | `INC_APPEND_HISTORY`, `SHARE_HISTORY`, `HIST_FCNTL_LOCK` |
| `functions.zsh` | `colormap`, `fix_wsl2_interop` |
| `tools.zsh` | nvm, bun completions |
| `greeting.zsh` | pokemon-colorscripts piped into fastfetch as its logo |

`install.sh` clones `zsh-autosuggestions` and `zsh-syntax-highlighting` into
`$ZSH_CUSTOM/plugins/` — `plugins.zsh` references them, but oh-my-zsh does not
bundle them.

### VSCode

Config lives at `~/.config/Code/User` on Linux and
`~/Library/Application Support/Code/User` on macOS; `install.sh` picks the right
one from `uname -s`.

`vscode/settings.json`, `keybindings.json`, `mcp.json` and `snippets/` are
symlinked into the default profile. Five named profiles are tracked under
`vscode/profiles/`, each with its own `extensions.txt`:

| Profile | Extensions | Beyond the shared base |
|---|--:|---|
| Base | 13 | Docker, GitLens, YAML, TOML, Error Lens, Todo Tree, Material icons |
| Python Backend | 26 | Python, Pylance, debugpy, Ruff, Remote SSH, opencode |
| ML Research | 32 | Python + Jupyter suite, Data Wrangler, Rainbow CSV |
| Frontend | 17 | ESLint, Prettier, Tailwind |
| Go Backend | 19 | Go, Remote SSH, opencode |

`vscode/extensions.txt` is the union of all five (38 extensions) and is what
gets installed into the default, profile-less window.

Profile directories on disk are named by an opaque per-machine hash
(`profiles/-3219acd6/`) rather than by profile name, so `install.sh` resolves
name → directory through `globalStorage/storage.json` at install time instead of
hardcoding it. A profile that does not exist yet is created by
`code --profile "<name>" --install-extension`; re-run `make install` afterwards
to link its settings.

## Secrets

Nothing secret is committed. Tokens live in `~/.zshenv.local`, which is
gitignored and sourced from `~/.zshenv` — so scripts get them too, not just
interactive shells.

`make install` copies `zsh/zshenv.local.example` to `~/.zshenv.local` with mode
`600` if it does not already exist, and never overwrites it. Fill in:

```bash
export KAGGLE_KEY=''    # https://www.kaggle.com/settings/account
export GITHUB_TOKEN=''  # https://github.com/settings/tokens
export HF_TOKEN=''      # https://huggingface.co/settings/tokens
```

`KAGGLE_USERNAME` is not a secret and stays in `zsh/exports.zsh`.
`OLLAMA_API_KEY=ollama` is a required-but-ignored placeholder for a local Ollama
server, not a credential.

## Installing

`install.sh` is idempotent: a symlink already pointing at the right target is
left alone, so re-running it is a no-op. It never deletes anything. An existing
real file is moved to `<file>.backup` (then `.backup.1`, `.backup.2`, … so
earlier backups survive), and every replacement asks first unless `--yes`.

| Command | Effect |
|---|---|
| `make install` | Everything, interactive |
| `make dry-run` | Print the plan, change nothing |
| `make shell` | Only shell configs |
| `make vscode` | Only VSCode: config + extensions |
| `make extensions` | Only VSCode extensions |
| `make check` | Syntax-check `install.sh` and every zsh module |
| `make clean-backups` | List `*.backup` files (lists only, never deletes) |
| `./install.sh --yes` | Non-interactive, for provisioning a fresh machine |

## Prerequisites

The installer sets up oh-my-zsh plugins but does not install system packages.
On a fresh machine:

```bash
# Ubuntu
sudo apt install zsh git nano fastfetch
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s "$(which zsh)"
```

Also expected by one module or another, all optional — the shell starts fine
without them: `lsd`, `bat`, `wl-clipboard`, `pokemon-colorscripts`, `fastfetch`,
`nvm`, `bun`, `direnv`.

## legacy/

Configs this repo used to install, superseded by the current live setup and kept
only for reference. Nothing here is symlinked:

- `zshrc.starship-p10k` — the previous `.zshrc`: powerlevel10k + starship, and a
  different oh-my-zsh plugin set. The live shell uses `agnosterzak`.
- `p10k.zsh` — powerlevel10k theme config, unused since the theme changed.
- `starship.zsh` — distro/device detection feeding starship's prompt icons.
- `aliases.macos.zsh` — macOS-only aliases (`gls`, `pbcopy`, `open -a`).
