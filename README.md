# Dotfiles by Nikita Kolesnikov

Этот репозиторий содержит мои личные настройки для терминала, оболочек Zsh и Bash, а также кастомизированный Powerlevel10k prompt. Поддерживает Linux, macOS и WSL.

## Включает

- 🐚 `.zshrc` — конфигурация Zsh с автокомплитом, алиасами и поддержкой Powerlevel10k
- 🎨 `.p10k.zsh` — тема Powerlevel10k с информативным git prompt и путём
- 🧪 `.bashrc`, `.bash_profile` — настройки для bash (наследие и fallback)
- ✅ Совместимость с Warp (macOS), iTerm2, и Linux-терминалами

## Установка

```bash
git clone https://github.com/fgeeha/dotfiles.git ~
cd ~
stow shell
```

Убедитесь, что установлен Zsh и Powerlevel10k:

- macOS:
```bash
brew install zsh git powerlevel10k direnv
curl -sS https://starship.rs/install.sh | sh
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
```

- Ubuntu:

```bash
sudo apt install zsh git direnv
# starship
curl -sS https://starship.rs/install.sh | sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
```

После установки:

```bash
chsh -s $(which zsh)
```
