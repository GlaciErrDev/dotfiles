#!/usr/bin/env bats
#
# tests/suite.bats -- in-guest e2e suite for the dotfiles install.
#
# Runs *inside* a fresh guest VM (Ubuntu via multipass, macOS via tart)
# after the orchestrator (scripts/test-e2e.sh) has:
#   1. mounted the repo into the guest,
#   2. installed the guest prerequisites (base tooling, CPython build
#      deps, linuxbrew on ubuntu; brew/CLT verification on macOS),
#   3. run `make setup` non-interactively,
#   4. synced the LazyVim plugins headlessly and exported :checkhealth
#      to /tmp/nvim-health.txt.
#
# It asserts what that pipeline owns:
#   * every dotbot symlink from install.conf.yaml exists and resolves
#   * the dotbot-created directories and private override files exist
#   * the base binaries the repo configures (git, zsh, nvim) are on PATH
#   * the global git configuration from the repo's gitconfig is applied
#   * everything `make setup` adds: brew CLI packages, Tmux TPM,
#     pyenv + the pinned Python + pip tools, nodenv + the pinned Node +
#     npm globals, fzf, the LazyVim config, the headless :checkhealth
#     report, and the ~/bin/nv symlink
#
# The suite is OS-agnostic: the same file must pass on both guests.
# Do not add Ubuntu- or macOS-only checks here.

# Every home-side target of a dotbot `link` in install.conf.yaml.
# Keep in sync with install.conf.yaml (and the "Dotbot symlink map" in AGENTS.md).
DOTBOT_LINKS=(
  "$HOME/bin"
  "$HOME/.fonts"
  "$HOME/.aliases"
  "$HOME/.zsh_functions"
  "$HOME/.gitconfig"
  "$HOME/.gitignore"
  "$HOME/.tmux.conf"
  "$HOME/.tmux/plugins/tmux/custom"
  "$HOME/.zshrc"
  "$HOME/.config/flake8"
  "$HOME/.config/bat"
  "$HOME/.config/yazi"
  "$HOME/.config/btop/themes"
  "$HOME/.config/stylua.toml"
  "$HOME/.config/yapf"
  "$HOME/.config/nvim/lua"
  "$HOME/.config/nvim/after"
  "$HOME/.omp/agent/config.yml"
  "$HOME/.omp/agent/models.yml"
  "$HOME/.omp/plugins/package.json"
  "$HOME/.omp/puppeteer/package.json"
  "$HOME/.hammerspoon/init.lua"
)

# The classic `fail [message]` helper: print the message to stderr and fail
# the test. Provided here because the bats-core 1.x runtime does not define
# it (it existed in bats 0.x), which keeps the suite portable across the
# bats versions used on the guests (1.10+ via tarball, latest via brew).
fail() {
  if [ "$#" -gt 0 ]; then
    printf '%s\n' "$*" >&2
  fi
  return 1
}

# assert_link <path>
# A dotbot link must be a symlink AND must resolve to an existing file/dir.
assert_link() {
  local target="$1"
  [ -L "$target" ] || fail "$target is not a symlink (dotbot link missing)"
  [ -e "$target" ] || fail "$target is a broken symlink -> $(readlink "$target")"
}

# assert_global_git <key> <expected>
assert_global_git() {
  local key="$1" expected="$2" actual
  run git config --global "$key"
  [ "$status" -eq 0 ] || fail "git config --global $key failed (is ~/.gitconfig installed?)"
  actual="$output"
  [ "$actual" = "$expected" ] || fail "git config --global $key = '$actual', expected '$expected'"
}

# PATH where `make setup` installs its tooling: dotbot ~/bin, pyenv/nodenv
# shims, the npm-global prefix, the Homebrew prefix (OS-aware), and the fzf
# binary prefix -- the fzf installer downloads a prebuilt binary into
# ~/.fzf/bin, and the generated ~/.fzf.zsh (sourced by the repo's zshrc)
# puts exactly that directory on PATH.
setup() {
  local brew_prefix
  if [ -d /opt/homebrew/bin ]; then
    brew_prefix=/opt/homebrew
  else
    brew_prefix=/home/linuxbrew/.linuxbrew
  fi
  export PATH="$HOME/bin:$HOME/.pyenv/shims:$HOME/.pyenv/bin:$HOME/.nodenv/shims:$HOME/.nodenv/bin:$HOME/.npm-global/bin:${brew_prefix}/bin:$HOME/.fzf/bin:$PATH"
}

# makefile_pin <VAR>
# Reads a `VAR=value` pin from the mounted Makefile instead of hardcoding
# versions: the pins change (2026-10-06: python 3.12.4 -> 3.14.8, node
# 20.16.0 -> 24.21.0) and hardcoded copies rot immediately.
makefile_pin() {
  sed -n "s/^$1=//p" "$BATS_TEST_DIRNAME/../Makefile" | head -n 1
}

@test "the dotfiles repo is present" {
  # BATS_TEST_DIRNAME is tests/; the repo root sits right above it.
  [ -f "$BATS_TEST_DIRNAME/../install.conf.yaml" ] \
    || fail "install.conf.yaml not found next to tests/ (repo not mounted?)"
}

@test "dotbot symlinks exist and resolve" {
  local target
  for target in "${DOTBOT_LINKS[@]}"; do
    assert_link "$target"
  done
}

@test "shell rc files point to valid paths" {
  # ~/.zshrc is the essential shell config for this repo (no bash is set up).
  assert_link "$HOME/.zshrc"
  # The rc sources these override files in every interactive shell.
  [ -f "$HOME/.aliases" ]         || fail "~/.aliases missing"
  [ -f "$HOME/.zsh_functions" ]   || fail "~/.zsh_functions missing"
  [ -f "$HOME/.private_aliases" ] || fail "~/.private_aliases missing (install.sh should create it)"
  [ -f "$HOME/.private_functions" ] || fail "~/.private_functions missing (install.sh should create it)"
  [ -f "$HOME/.additional_exports" ] || fail "~/.additional_exports missing (install.sh should create it)"
}

@test "installed zshrc has valid zsh syntax" {
  # -n parses without executing: no side effects, safe on a bare guest.
  run zsh -n "$HOME/.zshrc"
  [ "$status" -eq 0 ] || fail "zsh -n ~/.zshrc failed: $output"
}

@test "dotbot-created directories exist" {
  local dir
  for dir in "$HOME/.gem" "$HOME/Projects" "$HOME/tools"; do
    [ -d "$dir" ] || fail "$dir is missing (dotbot 'create' should make it)"
  done
}

@test "git is available in PATH" {
  command -v git >/dev/null || fail "git not found in PATH"
}

@test "zsh is available in PATH" {
  command -v zsh >/dev/null || fail "zsh not found in PATH"
}

@test "nvim is available in PATH" {
  # The repo configures nvim as the editor (~/.gitconfig core.editor=nv,
  # zshrc EDITOR=nv); the orchestrator installs it in the guest.
  command -v nvim >/dev/null || fail "nvim not found in PATH"
}

@test "global git config: user.email" {
  assert_global_git user.email "GlaciErrDev@users.noreply.github.com"
}

@test "global git config: init.defaultBranch" {
  assert_global_git init.defaultBranch "main"
}

@test "global git config: core.editor" {
  assert_global_git core.editor "nv"
}

@test "global git config: alias.poo" {
  assert_global_git alias.poo "push origin HEAD"
}

@test "global git config: core.excludesfile" {
  assert_global_git core.excludesfile "~/.dotfiles/gitignore"
}

# --- `make setup` assertions (beyond what dotbot owns) ---------------------

@test "brew CLI packages are on PATH" {
  local tool
  for tool in nvim tmux rg jq eza btop gh bat fd zoxide yazi; do
    command -v "$tool" >/dev/null || fail "$tool not found in PATH (brew install)"
  done
}

@test "tmux plugin manager is installed" {
  [ -d "$HOME/.tmux/plugins/tpm" ] || fail "~/.tmux/plugins/tpm is missing"
  [ -n "$(ls -A "$HOME/.tmux/plugins/tpm" 2>/dev/null)" ] \
    || fail "~/.tmux/plugins/tpm is empty (tpm clone failed?)"
}

@test "pyenv is installed" {
  command -v pyenv >/dev/null || fail "pyenv not found in PATH"
}

@test "python version matches the Makefile pin" {
  local expected actual
  expected="$(makefile_pin PYTHON_VERSION)"
  [ -n "$expected" ] || fail "PYTHON_VERSION not found in the Makefile"
  run python --version
  [ "$status" -eq 0 ] || fail "python --version failed: $output"
  actual="$output"
  [ "$actual" = "Python $expected" ] \
    || fail "python --version = '$actual', expected 'Python $expected'"
}

@test "python tooling is on PATH" {
  local tool
  for tool in mypy black pyright flake8 ipython; do
    command -v "$tool" >/dev/null || fail "$tool not found in PATH (pip install)"
  done
}

@test "nodenv is installed" {
  command -v nodenv >/dev/null || fail "nodenv not found in PATH"
}

@test "node version matches the Makefile pin" {
  local expected actual
  expected="$(makefile_pin NODE_VERSION)"
  [ -n "$expected" ] || fail "NODE_VERSION not found in the Makefile"
  run node --version
  [ "$status" -eq 0 ] || fail "node --version failed: $output"
  actual="$output"
  [ "$actual" = "v$expected" ] || fail "node --version = '$actual', expected 'v$expected'"
}

@test "npm global packages are on PATH" {
  local tool
  for tool in tree-sitter nodemon; do
    command -v "$tool" >/dev/null || fail "$tool not found in PATH (npm install -g)"
  done
}

@test "fzf is installed" {
  [ -d "$HOME/.fzf" ] || fail "~/.fzf is missing (fzf clone failed?)"
  run fzf --version
  [ "$status" -eq 0 ] || fail "fzf --version failed: $output"
}

@test "lazyvim config is installed" {
  [ -d "$HOME/.config/nvim" ] || fail "~/.config/nvim is missing (install-lazyvim failed?)"
}

@test "neovim health report was generated" {
  [ -s /tmp/nvim-health.txt ] || fail "/tmp/nvim-health.txt is missing or empty"
  # Standard :checkhealth plain-text layout, identical across the nvim
  # versions both guests install: "component: <counts>" section headers,
  # "subsection ~" headings, "- <emoji> OK/WARNING/ERROR/..." status lines.
  grep -qE '^[a-zA-Z][a-zA-Z0-9._-]*: ' /tmp/nvim-health.txt \
    || fail "health report has no 'component:' section headers"
  grep -qE ' ~$' /tmp/nvim-health.txt \
    || fail "health report has no 'subsection ~' headings"
  grep -qE '^- .*(OK|WARNING|ERROR|INFO)' /tmp/nvim-health.txt \
    || fail "health report has no OK/WARNING/ERROR status lines"
}

@test "~/bin/nv is a symlink to nvim" {
  # post-install links ~/bin/nv to the brew prefix' nvim (OS-aware).
  [ -L "$HOME/bin/nv" ] \
    || fail "~/bin/nv is not a symlink (post-install should create it)"
  # The ubuntu guest's sshfs-mounted repo cannot follow in-mount symlinks,
  # and the developer machine's bin/nv points at a macOS path that is
  # absent in that guest -- so the link is dangling there by design. Where
  # the filesystem does resolve it (macOS guest), it must be a working nvim.
  if [ -e "$HOME/bin/nv" ]; then
    run "$HOME/bin/nv" --version
    [ "$status" -eq 0 ] || fail "~/bin/nv --version failed: $output"
    printf '%s\n' "$output" | grep -qi nvim \
      || fail "~/bin/nv does not report nvim: $output"
  fi
}
