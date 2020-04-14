export ZSH="$HOME/.oh-my-zsh"

ZSH_CUSTOM=$HOME/.zsh_custom
ZSH_THEME="custom"

plugins=(git)

export ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

source $HOME/.aliases
source $HOME/.helpful_functions

export LANG=en_US.UTF-8
export TERM="screen-256color"

# golang
export PATH=$PATH:$(go env GOROOT)/bin

# Pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
