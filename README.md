# Dotfiles by Nikita Kolesnikov

Этот репозиторий содержит мои личные настройки для терминала, оболочек Zsh и Bash, а также кастомизированный Powerlevel10k prompt. Поддерживает Linux, macOS и WSL.

## Включает

- 🐚 `.zshrc` — конфигурация Zsh с автокомплитом, алиасами и поддержкой Powerlevel10k
- 🎨 `.p10k.zsh` — тема Powerlevel10k с информативным git prompt и путём
- 🧪 `.bashrc`, `.bash_profile` — настройки для bash (наследие и fallback)
- ✅ Совместимость с Warp (macOS), iTerm2, и Linux-терминалами

## Установка

```bash
cd ~
git clone https://github.com/fgeeha/dotfiles.git ~ && cd dotfiles
cp . ../
```

Убедитесь, что установлен Zsh и ohmyzsh:

- macOS:
```bash
brew install zsh git direnv
# starship
curl -sS https://starship.rs/install.sh | sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- Ubuntu:

```bash
sudo apt install zsh git direnv
# starship
curl -sS https://starship.rs/install.sh | sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

После установки:

```bash
chsh -s $(which zsh)
```
