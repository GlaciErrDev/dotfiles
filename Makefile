.DEFAULT_GOAL := help

GOLANG_VERSION=1.18
PYTHON_VERSION=3.11.1
NODE_VERSION=16.15.0
RG_VERSION=13.0.0
DOCKER_COMPOSE_VERSION=1.25.4

.PHONY: setup
setup: install-dotfiles \
  install-packages \
  install-tpm \
  install-pyenv-python \
  install-nodenv-node \
  install-fzf \
  install-oh-my-zsh ## Install development environment

.PHONY: install-dotfiles
install-dotfiles: ## Install dotfiles
	@printf "\033[92m=========Install dotfiles=========\033[0m\n\n"
	@./install.sh

.PHONY: install-golang
install-golang: ## Install golang
	@printf "\033[92m=========Install golang=========\033[0m\n\n"
	@curl -fsSL https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz
	@sudo tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz

.PHONY: install-packages
install-packages: ## Install brew packages
	@printf "\033[92m=========Install all packages=========\033[0m\n\n"
	@brew install \
	  tmux \
	  neovim \
	  golang \
	  exa \
	  htop \
	  urlview \
	  ripgrep \
	  jq \
	  markdownlint \
	  gh \
	  markdownlint-cli \
	  codespell \
	  shellcheck \
      gnu-sed

.PHONY: install-tpm
install-tpm: ## Install tmux plugin manager
	@printf "\033[92m=========Install tmux plugin manager=========\033[0m\n\n"
	@git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

.PHONY: install-neovim
install-neovim: ## Install neovim
	@printf "\033[92m=========Install neovim=========\033[0m\n\n"
	@sudo curl -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -o /usr/local/bin/nv
	@sudo chmod +x /usr/local/bin/nv

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
	@PATH=$(PYENV_PATH) pip install flake8 mypy pylint black neovim yapf rope ipython pyright

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
	@PATH=$(NODENV_PATH) npm install -g neovim tree-sitter-cli

.PHONY: install-hombrew
install-hombrew: ## Install homebrew
	@printf "\033[92m=========Install homebrew=========\033[0m\n\n"
	@/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: install-rust
install-rust: ## Install rust
	@printf "\033[92m=========Install rust=========\033[0m\n\n"
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

.PHONY: install-ripgrep
install-ripgrep: ## Install ripgrep
	@printf "\033[92m=========Install ripgrep=========\033[0m\n\n"
	@curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb
	@sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb
	@rm ripgrep_${RG_VERSION}_amd64.deb

.PHONY: install-fzf
install-fzf: ## Install fzf
	@printf "\033[92m=========Install fzf=========\033[0m\n\n"
	@rm -rf ${HOME}/.fzf
	@git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
	@yes | ${HOME}/.fzf/install

.PHONY: install-docker-compose
install-docker-compose: ## Install docker-compose
	@printf "\033[92m=========Install docker-compose=========\033[0m\n\n"
	@sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	@sudo chmod +x /usr/local/bin/docker-compose

.PHONY: install-oh-my-zsh
install-oh-my-zsh: ## Install oh-my-zsh
	@printf "\033[92m=========Install oh-my-zsh=========\033[0m\n\n"
	@rm -rf ${HOME}/.oh-my-zsh
	@git clone https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh
	if [ $SHELL != "/bin/zsh" ]; then chsh -s /bin/zsh; fi;

.PHONY: help
# got from :https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# but disallow underscore in command names as we want some private to have format "_command-name"
help: ## print command reference, same as just `make`
	@printf "  Welcome to \033[94mpackage install\033[0m command refference.\n"
	@printf "  Usage:\n    \033[94mmake <target> [..arguments]\033[0m\n\n  Targets:\n"
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[94m%-20s\033[0m\t%s\n", $$1, $$2}'
