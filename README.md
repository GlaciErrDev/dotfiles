# Dotfiles

Personal macOS development environment configuration.

## Features

- Neovim (LazyVim) with full Lua config
- Tmux with plugins and catppuccin theme
- Zsh with oh-my-zsh and custom functions
- CLI tools: ripgrep, fd, bat, eza, btop, fzf, zoxide

## Installation

```bash
git clone git@github.com:glacierrdev/dotfiles.git "${HOME}/.dotfiles"
cd "${HOME}/.dotfiles"
make setup
```

**Note:** `oh-my-zsh` requires password to change default shell.

## Prerequisites

**macOS:** Homebrew (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`)

**Linux:** `sudo apt install git curl build-essential`

## Customization

Create these files for personal overrides:

- `~/.private_aliases` - Custom aliases
- `~/.private_functions` - Custom shell functions
- `~/.additional_exports` - Additional environment variables

## Tools Included

**Editor:** Neovim (LazyVim)

**Shell:** Zsh, Tmux, Fzf, Zoxide

**CLI:** ripgrep, fd, eza, bat, btop, jq, yazi

**Languages:** Python 3.12.4, Node 20.16.0, Go

**Dev Tools:** Black, Pylint, Mypy, Pyright, Flake8, StyLua, YAPF

## Updates

```bash
cd ~/.dotfiles
git pull && make setup
```
