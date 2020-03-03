.DEFAULT_GOAL := help

PYTHON_VERSION=3.7.6
NPM_VERSION=12.16.0
RG_VERSION=11.0.2
DOCKER_COMPOSE_VERSION=1.25.4

.PHONY: setup
setup: checkplatform install-dotfiles update-upgrade add-alacritty-repo apt-install-packages install-neovim install-pyenv-python install-nodenv-node-yarn install-ripgrep install-fzf install-docker install-docker-compose install-starship install-oh-my-zsh  ## Install all things for development environment
	@printf "=========Installing all packages and libraries=========\n\n"

.PHONY: checkplatform
checkplatform: ## Check platform for installation
ifneq ($(shell uname),Linux)
	@echo 'Platform unsupported, only available for Linux'  && exit 1
endif
ifneq ($(shell lsb_release -s -r),18.04)
	@echo 'Platform unsupported, only available for Ubuntu 18.04'  && exit 1
endif
ifeq ($(strip $(shell which apt-get)),)
	@echo 'Platform unsupported, apt-get not found' && exit 1
endif

.PHONY: install-dotfiles
install-dotfiles: ## Install dotfiles
	@printf "=========Install dotfiles=========\n\n"
	@./install.sh

.PHONY: update-upgrade
update-upgrade: ## Update info from sources and upgrade local packages
	@printf "=========Update && Upgrade=========\n\n"
	@sudo apt update && sudo apt upgrade -y

.PHONY: add-alacritty-repo
add-alacritty-repo: ## Add repo with alacritty deb
	@printf "=========Add repo with alacritty deb=========\n\n"
	@sudo add-apt-repository -y ppa:mmstick76/alacritty

.PHONY: apt-install-packages
apt-install-packages: ## Install all packages and libraries with `apt intsall`
	@printf "=========Add repo with alacritty deb=========\n\n"
	@sudo apt install -y alacritty tmux make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libedit-dev libncurses5-dev libncursesw5-dev xz-utils exuberant-ctags tk-dev libffi-dev liblzma-dev python-openssl git apt-transport-https ca-certificates software-properties-common zsh

.PHONY: install-neovim
install-neovim: ## Install neovim
	@printf "=========Install neovim=========\n\n"
	@sudo curl -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -o /usr/local/bin/nv
	@sudo chmod +x /usr/local/bin/nv

.PHONY: install-pyenv-python
install-pyenv-python: install-pyenv install-python  ## Install pyenv and python

.PHONY: install-pyenv
install-pyenv: ## Install pyenv
	@printf "=========Install pyenv=========\n\n"
	@rm -rf ${HOME}/.pyenv
	@curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

.PHONY: install-python
install-python: ## Install python
	@printf "=========Install python=========\n\n"
	@export PATH="$HOME/.pyenv/bin:$PATH"
	@eval "$(pyenv init -)"
	@pyenv install ${PYTHON_VERSION} -v
	@pyenv global ${PYTHON_VERSION}

.PHONY: install-nodenv-node-yarn
install-nodenv-node-yarn: install-nodenv install-node install-yarn  ## Install nodenv and node

.PHONY: install-nodenv
install-nodenv: ## Install nodenv
	@printf "=========Install nodenv=========\n\n"
	@rm -rf ${HOME}/.nodenv
	@curl -fsSL https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer | bash

.PHONY: install-node
install-node: ## Install node
	@printf "=========Install node=========\n\n"
	@export PATH="$HOME/.nodenv/bin:$PATH"
	@eval "$(nodenv init -)"
	@nodenv install ${NPM_VERSION} -v
	@nodenv global ${NPM_VERSION}

.PHONY: install-yarn
install-yarn: ## Install yarn
	@printf "=========Install yarn=========\n\n"
	@npm install yarn -g

.PHONY: install-ripgrep
install-ripgrep: ## Install ripgrep
	@printf "=========Install ripgrep=========\n\n"
	@curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb
	@sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb
	@rm ripgrep_${RG_VERSION}_amd64.deb

.PHONY: install-fzf
install-fzf: ## Install fzf
	@printf "=========Install fzf=========\n\n"
	@rm -rf ${HOME}/.fzf
	@git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
	@yes | ${HOME}/.fzf/install

.PHONY: install-docker
install-docker: ## Install docker
	@printf "=========Install docker=========\n\n"
	@curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	@echo "NOTE: Ubuntu 18.04 Bionic"
	@sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
	@sudo apt update
	@sudo apt install -y docker-ce
	@sudo systemctl status docker | cat
	@sudo usermod -aG docker ${USER}

.PHONY: install-docker-compose
install-docker-compose: ## Install docker-compose
	@printf "=========Install docker-compose=========\n\n"
	@sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	@sudo chmod +x /usr/local/bin/docker-compose

.PHONY: install-starship
install-starship: ## Install starship prompt
	@printf "=========Install starship prompt=========\n\n"
	@curl -L https://starship.rs/install.sh -o starship-install.sh
	@chmod +x starship-install.sh
	@./starship-install.sh -y
	@rm starship-install.sh

.PHONY: install-oh-my-zsh
install-oh-my-zsh: ## Install oh-my-zsh
	@printf "=========Install oh-my-zsh=========\n\n"
	@rm -rf ${HOME}/.oh-my-zsh
	@git clone https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh
	chsh -s $(shell which zsh)


.PHONY: help
# got from :https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# but disallow underscore in command names as we want some private to have format "_command-name"
help: ## print command reference, same as just `make`
	@printf "  Welcome to \033[36mpackage install\033[0m command refference.\n"
	@printf "  Usage:\n    \033[36mmake <target> [..arguments]\033[0m\n\n  Targets:\n"
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[36m%-20s\033[0m %s\n", $$1, $$2}'
