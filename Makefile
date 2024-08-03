.DEFAULT_GOAL := help

PYTHON_VERSION=3.12.4
NODE_VERSION=20.16.0
FLUTTER_VERSION=3.22.0
.PHONY: setup
setup: install-dotfiles \
  install-packages \
  install-tmux \
  install-pyenv-python \
  install-nodenv-node \
  install-fzf \
	install-flutter \
	install-lazyvim \
  install-oh-my-zsh ## Install development environment

.PHONY: install-dotfiles
install-dotfiles: ## Install dotfiles
	@printf "\033[92m=========Install dotfiles=========\033[0m\n\n"
	@./install.sh


.PHONY: install-packages
install-packages: install-brew-casks install-brew-packages ## Install all tools and packages

.PHONY: install-brew-casks
install-brew-casks: ## Install brew casks
	@printf "\033[92m=========Install brew casks=========\033[0m\n\n"
	@brew tap homebrew/cask-fonts
	@brew install --cask \
		lulu \
		hiddenbar \
		font-hack-nerd-font

.PHONY: install-brew-packages
install-brew-packages: ## Install brew packages
	@printf "\033[92m=========Install brew packages=========\033[0m\n\n"
	@brew install \
	  tmux \
	  tmux-xpanes \
	  neovim \
	  golang \
	  eza \
	  btop \
	  urlview \
	  ripgrep \
	  jq \
	  gh \
	  markdownlint-cli \
	  codespell \
	  shellcheck \
	  cocoapods \
		bat \
		tealdeer \
		git-delta \
    gnu-sed

.PHONY: install-tmux
install-tmux: install-tmux-plugin-manager install-tmux-plugins update-tmux-plugins ## Install tmux and plugins

.PHONY: install-tmux-plugin-manager
install-tmux-plugin-manager: ## Install tmux plugin manager
	@printf "\033[92m=========Install tmux plugin manager=========\033[0m\n\n"
	@rm -rf ${HOME}/.tmux/plugins/tpm
	@git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm

.PHONY: install-tmux-plugins
install-tmux-plugins: ## Install tmux plugins
	@printf "\033[92m=========Install tmux plugins=========\033[0m\n\n"
	@${HOME}/.tmux/plugins/tpm/bin/install_plugins

.PHONY: update-tmux-plugins
update-tmux-plugins: ## Update tmux plugins
	@printf "\033[92m=========Update tmux plugins=========\033[0m\n\n"
	@${HOME}/.tmux/plugins/tpm/bin/update_plugins all

.PHONY: install-pyenv-python
install-pyenv-python: install-pyenv install-python install-python-packages ## Install pyenv and python

.PHONY: install-pyenv
install-pyenv: ## Install pyenv
	@printf "\033[92m=========Install pyenv=========\033[0m\n\n"
	@rm -rf ${HOME}/.pyenv
	@curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

PYENV_PATH="${HOME}/.pyenv/bin:${PATH}"
.PHONY: install-python
install-python: ## Install python
	@printf "\033[92m=========Install python=========\033[0m\n\n"
	@PATH=$(PYENV_PATH) env | grep -i path
	@PATH=$(PYENV_PATH) eval "$(pyenv init -)"
	@PATH=$(PYENV_PATH) pyenv install ${PYTHON_VERSION} -v
	@PATH=$(PYENV_PATH) pyenv global ${PYTHON_VERSION}

.PHONY: install-python-packages
install-python-packages: ## Install python global packages
	@printf "\033[92m=========Install python global packages=========\033[0m\n\n"
	@PATH=$(PYENV_PATH) pip install flake8 mypy pylint black neovim ipython pyright

.PHONY: install-nodenv-node
install-nodenv-node: install-nodenv install-node set-npm-global-directory install-node-packages  ## Install nodenv and node

NODENV_PATH="${HOME}/.nodenv/bin:${HOME}/.nodenv/shims:${PATH}"
.PHONY: install-nodenv
install-nodenv: ## Install nodenv
	@printf "\033[92m=========Install nodenv=========\033[0m\n\n"
	@rm -rf ${HOME}/.nodenv
	@curl -LO https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer
	@sudo chmod +x nodenv-installer
	@PATH=$(NODENV_PATH) ./nodenv-installer
	@rm nodenv-installer

.PHONY: install-node
install-node: ## Install node
	@printf "\033[92m=========Install node=========\033[0m\n\n"
	@PATH=$(NODENV_PATH) eval "$(nodenv init -)"
	@PATH=$(NODENV_PATH) nodenv install ${NODE_VERSION} -v
	@PATH=$(NODENV_PATH) nodenv global ${NODE_VERSION}

.PHONY: set-npm-global-directory
set-npm-global-directory: ## Install npm global directory
	@printf "\033[92m=========Set npm global directory=========\033[0m\n\n"
	@mkdir ~/.npm-global
	@PATH=$(NODENV_PATH) npm config set prefix '~/.npm-global'

.PHONY: install-node-packages
install-node-packages: ## Install node packages
	@printf "\033[92m=========Install npm packages=========\033[0m\n\n"
	@PATH=$(NODENV_PATH) npm install -g neovim tree-sitter-cli nodemon

.PHONY: install-hombrew
install-hombrew: ## Install homebrew
	@printf "\033[92m=========Install homebrew=========\033[0m\n\n"
	@/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: install-rust
install-rust: ## Install rust
	@printf "\033[92m=========Install rust=========\033[0m\n\n"
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

.PHONY: install-fzf
install-fzf: ## Install fzf
	@printf "\033[92m=========Install fzf=========\033[0m\n\n"
	@rm -rf ${HOME}/.fzf
	@git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
	@yes | ${HOME}/.fzf/install

.PHONY: install-oh-my-zsh
install-oh-my-zsh: ## Install oh-my-zsh
	@printf "\033[92m=========Install oh-my-zsh=========\033[0m\n\n"
	@rm -rf ${HOME}/.oh-my-zsh
	@git clone https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh
	if [ ${SHELL} != "/bin/zsh" ]; then chsh -s /bin/zsh; fi;

.PHONY: install-flutter
# https://docs.flutter.dev/get-started/install/macos
install-flutter: ## Install Flutter
	@printf "\033[92m=========Install Flutter=========\033[0m\n\n"
	@curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_${FLUTTER_VERSION}-stable.zip
	@unzip flutter_macos_arm64_${FLUTTER_VERSION}-stable.zip -d ~/tools/
	@rm flutter_macos_arm64_${FLUTTER_VERSION}-stable.zip

.PHONY: install-lazyvim
install-lazyvim: ## Install Lazyvim
	@printf "\033[92m=========Install Lazyvim=========\033[0m\n\n"
	@if [ -d "$(HOME)/.config/nvim" ]; then  mv $(HOME)/.config/nvim $(HOME)/.config/nvim_`date +"%d-%m-%Y_%s"`; fi 
	@git clone https://github.com/LazyVim/starter $(HOME)/.config/nvim
	@rm -rf $(HOME)/.config/nvim/.git $(HOME)/.config/nvim/lua

.PHONY: help
# got from :https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# but disallow underscore in command names as we want some private to have format "_command-name"
help: ## print command reference, same as just `make`
	@printf "  Welcome to \033[94mpackage install\033[0m command refference.\n"
	@printf "  Usage:\n    \033[94mmake <target> [..arguments]\033[0m\n\n  Targets:\n"
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[94m%-20s\033[0m\t%s\n", $$1, $$2}'
