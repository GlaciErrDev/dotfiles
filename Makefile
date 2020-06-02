.DEFAULT_GOAL := help

GOLANG_VERSION=1.14/stable
PYTHON_VERSION=3.7.6
NPM_VERSION=12.16.0
RG_VERSION=11.0.2
DOCKER_COMPOSE_VERSION=1.25.4

.PHONY: setup
setup: checkplatform \
  install-dotfiles \
  update-upgrade \
  add-alacritty-repo \
  snap-install-golang \
  apt-install-packages \
  install-tpm \
  install-neovim \
  install-pyenv-python \
  install-nodenv-node-yarn \
  install-ripgrep \
  install-fzf \
  install-docker \
  install-docker-compose \
  install-oh-my-zsh ## Install development environment

.PHONY: checkplatform
checkplatform: ## Check platform for installation
	@printf "\033[92m=========Check platform=========\033[0m\n\n"
ifneq ($(shell uname),Linux)
	@echo '\033[91mPlatform unsupported, only available for Linux\033[0m\n'  && exit 1
endif
ifneq ($(shell lsb_release -s -r),$(filter $(shell lsb_release -s -r),18.04 20.04))
	@echo '\033[91mPlatform unsupported, only available for Ubuntu 18.04\033[0m\n'  && exit 1
endif
ifeq ($(strip $(shell which apt-get)),)
	@echo '\033[91mPlatform unsupported, apt-get not found\033[0m\n' && exit 1
endif
	@echo "\033[92mThis platform is supported.\033[0m\n"

.PHONY: install-dotfiles
install-dotfiles: ## Install dotfiles
	@printf "\033[92m=========Install dotfiles=========\033[0m\n\n"
	@./install.sh

.PHONY: update-upgrade
update-upgrade: ## Update info from sources and upgrade local packages
	@printf "\033[92m=========Update && Upgrade=========\033[0m\n\n"
	@sudo apt update && sudo apt upgrade -y

.PHONY: add-alacritty-repo
add-alacritty-repo: ## Add repo with alacritty deb
	@printf "\033[92m=========Add repo with alacritty deb=========\033[0m\n\n"
	@sudo add-apt-repository -y ppa:mmstick76/alacritty

.PHONY: snap-install-golang
snap-install-golang: ## Install golang
	@printf "\033[92m=========Install golang=========\033[0m\n\n"
	@sudo snap install --classic --channel=${GOLANG_VERSION} go

.PHONY: apt-install-packages
apt-install-packages: ## Install all packages and libraries with `apt intsall`
	@printf "\033[92m=========Add repo with alacritty deb=========\033[0m\n\n"
	@sudo apt install -y \
	  alacritty \
	  tmux \
	  make \
	  build-essential \
	  libssl-dev \
	  zlib1g-dev \
	  libbz2-dev \
	  libreadline-dev \
	  libsqlite3-dev \
	  wget \
	  curl \
	  llvm \
	  libedit-dev \
	  libncurses5-dev \
	  libncursesw5-dev \
	  xz-utils \
	  exuberant-ctags \
	  tk-dev \
	  libffi-dev \
	  liblzma-dev \
	  python-openssl \
	  git \
	  apt-transport-https \
	  ca-certificates \
	  software-properties-common \
	  zsh \
	  xsel \
	  urlview

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
install-pyenv-python: install-pyenv install-python  ## Install pyenv and python

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

.PHONY: install-nodenv-node-yarn
install-nodenv-node-yarn: install-nodenv install-node install-yarn  ## Install nodenv and node

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
	@PATH=$(NODENV_PATH) nodenv install ${NPM_VERSION} -v
	@PATH=$(NODENV_PATH) nodenv global ${NPM_VERSION}

.PHONY: install-yarn
install-yarn: ## Install yarn
	@printf "\033[92m=========Install yarn=========\033[0m\n\n"
	@PATH=$(NODENV_PATH) eval "$(nodenv init -)" && npm install yarn -g

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

.PHONY: install-docker
install-docker: ## Install docker
	@printf "\033[92m=========Install docker=========\033[0m\n\n"
	@curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	@echo "NOTE: Ubuntu 18.04 Bionic"
	@sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
	@sudo apt update
	@sudo apt install -y docker-ce
	@sudo systemctl status docker | cat
	@sudo usermod -aG docker ${USER}

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
	if [ $SHELL != "/bin/zsh" ]; then chsh -s $(which zsh); fi;


.PHONY: help
# got from :https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# but disallow underscore in command names as we want some private to have format "_command-name"
help: ## print command reference, same as just `make`
	@printf "  Welcome to \033[94mpackage install\033[0m command refference.\n"
	@printf "  Usage:\n    \033[94mmake <target> [..arguments]\033[0m\n\n  Targets:\n"
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[94m%-20s\033[0m\t%s\n", $$1, $$2}'
