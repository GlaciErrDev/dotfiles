#!/usr/bin/env bash


sudo apt update
sudo apt upgrade -y

sudo add-apt-repository -y ppa:mmstick76/alacritty

# Prerequisites
sudo apt install -y \
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
zsh

PYTHON_VERSION=3.7.6
NPM_VERSION=12.16.0
DOCKER_COMPOSE_VERSION=1.25.4

# Neovim
sudo curl -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -o /usr/local/bin/nv
sudo chmod +x /usr/local/bin/nv

# Pyenv + python
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
pyenv install ${PYTHON_VERSION} -v
pyenv global ${PYTHON_VERSION}

# Nodenv + npm
curl -fsSL https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer | bash
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
nodenv install ${NPM_VERSION} -v
nodenv global ${NPM_VERSION}
# ^
# |
# YARN
npm install yarn -g

# Ripgrep
RG_VERSION=11.0.2
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb
sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb
rm ripgrep_${RG_VERSION}_amd64.deb

# FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# NOTE: Ubuntu 18.04 Bionic
sudo add-apt-repository -y \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install -y docker-ce
sudo systemctl status docker | cat
sudo usermod -aG docker ${USER}

# docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Starship prompt
curl -L https://starship.rs/install.sh -o starship-install.sh
chmod +x starship-install.sh
./starship-install.sh -y
rm starship-install.sh

# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
