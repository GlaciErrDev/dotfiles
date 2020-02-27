export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="candy"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export TERM="screen-256color"

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(starship init zsh)"
