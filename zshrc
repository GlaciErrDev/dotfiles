# --- PATH helpers -------------------------------------------------------
# Idempotent PATH mutation: no-ops when the directory is already in PATH,
# so re-sourcing this file (or starting inside a shell that already ran it)
# can never create duplicate entries.
path-prepend() {
  local dir
  for dir in "$@"; do
    case ":${PATH}:" in
      *":${dir}:"*) ;;
      *) PATH="${dir}:${PATH}" ;;
    esac
  done
}

path-append() {
  local dir
  for dir in "$@"; do
    case ":${PATH}:" in
      *":${dir}:"*) ;;
      *) PATH="${PATH}:${dir}" ;;
    esac
  done
}

eval "$(/opt/homebrew/bin/brew shellenv)"

path-prepend /usr/local/sbin
path-prepend "$HOME/.local/bin"
path-prepend "$HOME/bin"

# --- completions -----------------------------------------------------------
# Native compinit (replaces oh-my-zsh): the completion dump is cached and
# re-scanned at most once a day (the marker file holds today's date).
autoload -Uz compinit
comp_dump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
mkdir -p "${comp_dump:h}"
comp_day="${comp_dump}.day"
if [[ -f "$comp_dump" && -f "$comp_day" && $(<"$comp_day") == "$(date +%Y-%m-%d)" ]]; then
  compinit -C -d "$comp_dump"
else
  compinit -d "$comp_dump"
  date +%Y-%m-%d > "$comp_day"
fi

# --- history ---------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# --- prompt ----------------------------------------------------------------
# [dir] in red, (venv) in blue, [branch] in green with a dirty/clean marker,
# -> in blue. PROMPT_SUBST makes the $(...) below expand on every display.
setopt PROMPT_SUBST

__prompt_info() {
  local info="" branch
  [[ -n $VIRTUAL_ENV ]] && info+=" $(virtualenv_info)"
  if branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
      branch=$(git rev-parse --short HEAD 2>/dev/null); then
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      info+=" %F{green}[$branch %F{red}✘%f%F{green}]%f"
    else
      info+=" %F{green}[$branch ✔]%f"
    fi
  fi
  print -r -- "$info"
}

PROMPT=$'%F{red}[%~]%f%F{blue}$(__prompt_info)%f %F{blue}->%f '

source $HOME/.aliases
source $HOME/.zsh_functions
source $HOME/.private_aliases
source $HOME/.private_functions
source $HOME/.additional_exports

export LANG=en_US.UTF-8

export EDITOR=nv


# java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-16.0.2.jdk/Contents/Home
# java end

# golang
path-append "$(go env GOPATH)/bin"
# golang end

# Pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.pyenv"
path-prepend "$PYENV_ROOT/bin"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
# pyenv end

# Nodenv
path-prepend "$HOME/.nodenv/bin"
eval "$(nodenv init -)"
# nodenv end

# Zoxide
eval "$(zoxide init --cmd cd zsh)"
# zoxide end

path-prepend "$HOME/.npm-global/bin"


# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
. "$HOME/.cargo/env"
path-prepend /opt/homebrew/opt/libpq/bin

# Zig
path-append "$HOME/Downloads/zig-macos"

# opencode
path-prepend "$HOME/.opencode/bin"

# Docker Podman
export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/podman.sock"
export PODMAN_COMPOSE_WARNING_LOGS=false

# bun
export BUN_INSTALL="$HOME/.bun"
path-prepend "$BUN_INSTALL/bin"
# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# De-duplicate PATH in place (keeps the first = highest-priority occurrence).
# Self-heals duplicates inherited from stale parent environments (tmux server
# environment, nested shells, tools that spawn login shells).
typeset -U path
