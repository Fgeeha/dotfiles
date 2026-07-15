# Thin wrapper over install.sh. Every target is idempotent and safe to re-run.
#
# `make` on its own prints this help.

.DEFAULT_GOAL := help
.PHONY: help install shell vscode extensions dry-run dump-extensions check clean-backups

INSTALL := ./install.sh

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

install: ## Install everything: shell configs + VSCode + extensions (interactive)
	@$(INSTALL)

shell: ## Only shell configs (zsh, bash, nano, warp, editorconfig)
	@$(INSTALL) --shell-only

vscode: ## Only VSCode: settings, keybindings, profiles, extensions
	@$(INSTALL) --vscode-only

extensions: ## Only VSCode extensions, skipping the config symlinks
	@$(INSTALL) --extensions-only

dry-run: ## Show what install would do, without changing anything
	@$(INSTALL) --dry-run

check: ## Syntax-check install.sh and every zsh module
	@bash -n $(INSTALL) && echo "install.sh: ok"
	@for f in zsh/*.zsh zsh/.zshrc zsh/.zshenv zsh/.zprofile; do \
		zsh -n "$$f" && echo "$$f: ok" || exit 1; \
	done

dump-extensions: ## Refresh extensions.txt from the VSCode currently installed here
	@code --list-extensions > /tmp/dotfiles-ext.txt 2>/dev/null || { \
		echo "the 'code' CLI is not on PATH"; exit 1; }
	@echo "wrote /tmp/dotfiles-ext.txt — diff it against vscode/extensions.txt before committing"

clean-backups: ## List the *.backup files install.sh has created (does not delete)
	@find $(HOME) -maxdepth 2 -name '*.backup*' 2>/dev/null || true
	@echo "(listing only — remove them yourself once you are happy with the install)"
