#!/usr/bin/env bash

sudo apt update
sudo apt upgrade -y

sudo add-apt-repository -y ppa:mmstick76/alacritty

# Prerequisites
sudo apt install -y \
alacritty \
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
tk-dev \
libffi-dev \
liblzma-dev \
python-openssl \
git \
apt-transport-https \
ca-certificates \
software-properties-common \
zsh 

# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Neovim
sudo curl -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -o /usr/local/bin/nv
sudo chmod +x /usr/local/bin/nv

# Pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

# Ripgrep
RG_VERSION=11.0.2
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb
sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb
rm ripgrep_${RG_VERSION}_amd64.deb

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install -y docker-ce
sudo systemctl status docker | cat
sudo usermod -aG docker ${USER}
su - ${USER}
docker --version

# docker-compose
DC_VERSION=1.25.4
sudo curl -L https://github.com/docker/compose/releases/download/${DC_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Starship prompt
curl -fsSL https://starship.rs/install.sh | bash


