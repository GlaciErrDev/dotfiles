# Dotfiles

Personal macOS development environment configuration.

## Features

- Neovim (LazyVim) with full Lua config
- Tmux with plugins and catppuccin theme
- Zsh with a native prompt, cached completions and custom functions
- CLI tools: ripgrep, fd, bat, eza, btop, fzf, zoxide

## Installation

```bash
git clone git@github.com:glacierrdev/dotfiles.git "${HOME}/.dotfiles"
cd "${HOME}/.dotfiles"
make setup
```

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

**Languages:** Python 3.14.8, Node 24.21.0, Go

**Dev Tools:** Black, Pylint, Mypy, Pyright, Flake8, StyLua, YAPF

## Updates

```bash
cd ~/.dotfiles
git pull && make setup
```

## Local e2e tests

Boots a disposable VM, mounts this repo into it, and runs the full
`make setup` inside the guest. Right after, the guest syncs the LazyVim
plugins headlessly (`nvim --headless "+Lazy! sync" +qa`) and exports
`:checkhealth` to a report file. The bats suite in `tests/suite.bats`
then verifies everything: dotbot symlinks, brew CLI packages, Tmux TPM,
pyenv/Python at the Makefile pin, nodenv/Node at the pin, fzf, the
LazyVim config, the health report, and the global git config. Each run
is disposable: the VM is deleted on completion (via trap, on every exit
path) and other multipass/tart instances are never touched.

| Target | Guest | How |
|---|---|---|
| `ubuntu` | Ubuntu 26.04 LTS (`dotfiles-ubuntu-test`) | `multipass`, repo mounted at `/home/ubuntu/dotfiles` |
| `macos` | macOS 27 "Golden Gate" (`dotfiles-macos-test`) | `tart` + `ghcr.io/cirruslabs/macos-golden-gate-base:latest`, repo mounted at `/Volumes/dotfiles` |

Host prerequisites:

```bash
brew install --cask multipass
```

- `multipass` must be the official cask (root LaunchDaemon); a
  user-level daemon is impossible (the daemon chowns its data dirs to
  root at startup).
- `tart` 2.40.x from the [CirrusLabs release
  tarball](https://github.com/cirruslabs/cli/releases) — the Homebrew
  formula `cirruslabs/cli/tart` is broken on Homebrew 7.
- The macOS image ref is
  `ghcr.io/cirruslabs/macos-golden-gate-base:latest` (the `-base` suffix
  is required). The image ships Homebrew and Xcode Command Line Tools.
- If you run the LuLu firewall, allow `multipass`/`multipassd`
  local-network traffic; otherwise the ubuntu guest is unreachable
  ("No route to host" while the route and DHCP lease still exist).

Guest prerequisites are installed per run inside the VM (not on the
host): base tooling + bats, CPython build deps (pyenv compiles CPython
from source), and Homebrew (linuxbrew) on the ubuntu guest; the macOS
guest verifies its shipped brew and CLT.

Usage:

```bash
./scripts/test-e2e.sh ubuntu   # Ubuntu guest only
./scripts/test-e2e.sh macos    # macOS guest only
./scripts/test-e2e.sh all      # both (default)
```

Artifacts land in `test-results/` (gitignored) and are kept on pass and
failure:

- `{os}-install.log` — streamed guest output (guest setup, linuxbrew,
  `make setup`, headless neovim, bats stderr)
- `{os}-report.xml` — JUnit report of the bats suite (also streamed to
  stdout)
- `{os}-nvim-health.txt` — the guest's `:checkhealth` report

The script exits `0` only if every requested target passes; `1`
otherwise.
