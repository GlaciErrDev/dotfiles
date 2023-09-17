export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"

# NOTE: openssl
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"

# NOTE: zlib
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"

# NOTE: sqlite
export PATH="/usr/local/opt/sqlite/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/sqlite/lib"
export CPPFLAGS="-I/usr/local/opt/sqlite/include"

# NOTE: readline
export LDFLAGS="-L/usr/local/opt/readline/lib"
export CPPFLAGS="-I/usr/local/opt/readline/include"

# NOTE: llvm
export PATH="/usr/local/opt/llvm/bin:$PATH"

# For compilers to find llvm you may need to set:
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"

ZSH_CUSTOM=$HOME/.zsh_custom
ZSH_THEME="custom"

plugins=(git)

export ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

source $HOME/.aliases
source $HOME/.zsh_functions
source $HOME/.private_aliases
source $HOME/.private_functions
source $HOME/.additional_exports

export LANG=en_US.UTF-8

# Cocoapods
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
export PATH=$GEM_HOME/ruby/2.6.0/bin:$PATH
# cocoapods end

# Flutter
export PATH="$PATH:$HOME/development/flutter/bin"
# flutter end

# java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-16.0.2.jdk/Contents/Home
# java end

# golang
export PATH=$PATH:$(go env GOPATH)/bin
# golang end

# Pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
# pyenv end

# Nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
# nodenv end

export PATH=~/.npm-global/bin:$PATH


# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
