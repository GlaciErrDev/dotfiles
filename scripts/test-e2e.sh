#!/usr/bin/env bash
#
# scripts/test-e2e.sh -- end-to-end dotfiles install tests on fresh VMs.
#
# Usage:
#   ./scripts/test-e2e.sh [ubuntu|macos|all]      (default: all)
#
# ubuntu: clean Ubuntu 26.04 LTS instance via multipass (dotfiles-ubuntu-test)
#         repo mounted at /home/ubuntu/dotfiles
# macos : clean macOS Golden Gate image via tart (dotfiles-macos-test)
#         ghcr.io/cirruslabs/macos-golden-gate-base:latest, repo mounted at /Volumes/dotfiles
#
# Each target:
#   1. boots a disposable VM with the repo mounted
#   2. installs the guest prerequisites:
#        ubuntu: base tooling + CPython build deps (root), then linuxbrew
#                into /home/linuxbrew/.linuxbrew (guest user; the installer
#                refuses to run as root on Linux)
#        macos : verifies the image ships brew and Xcode CLT (make/cc;
#                pyenv compiles CPython) and installs neovim/bats if missing
#   3. runs `make setup` non-interactively, logging to
#      test-results/<os>-install.log
#   4. syncs the nvim plugins headlessly (`Lazy! sync`), waits for the
#      mason tool installs to finish, then exports :checkhealth to
#      /tmp/nvim-health.txt in the guest, and copies the report to
#      test-results/<os>-nvim-health.txt
#   5. runs `bats --formatter junit tests/suite.bats`, streaming the JUnit
#      XML to stdout and capturing it in test-results/<os>-report.xml
#   6. deletes the VM
#
# Prerequisites (host):
#   brew install --cask multipass
#   tart 2.40.x from the CirrusLabs release tarball (the Homebrew formula
#   is broken on Homebrew 7 -- see README "Local e2e tests")
#   if LuLu is running: allow multipass/multipassd local-network traffic,
#   or the ubuntu guest is unreachable ("No route to host")
#
# Exit code: 0 when every requested target passes, 1 otherwise.
#
# Note: bash 3.2 compatible (macOS ships /usr/bin/bash 3.2).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_DIR="${REPO_ROOT}/test-results"

UBUNTU_VM="dotfiles-ubuntu-test"
UBUNTU_RELEASE="26.04"
UBUNTU_GUEST_REPO="/home/ubuntu/dotfiles"
UBUNTU_LOG="${RESULTS_DIR}/ubuntu-install.log"
UBUNTU_REPORT="${RESULTS_DIR}/ubuntu-report.xml"
UBUNTU_HEALTH="${RESULTS_DIR}/ubuntu-nvim-health.txt"

MACOS_VM="dotfiles-macos-test"
MACOS_IMAGE="ghcr.io/cirruslabs/macos-golden-gate-base:latest"
MACOS_GUEST_REPO="/Volumes/dotfiles"
MACOS_LOG="${RESULTS_DIR}/macos-install.log"
MACOS_REPORT="${RESULTS_DIR}/macos-report.xml"
MACOS_HEALTH="${RESULTS_DIR}/macos-nvim-health.txt"

BATS_VERSION="1.10.0"

FAILED_TARGETS=""
UBUNTU_VM_CREATED=0
MACOS_VM_CREATED=0
TART_RUN_PID=""

log() { printf '\n\033[1;34m== %s ==\033[0m\n' "$*"; }
warn() { printf '\033[1;33mwarn: %s\033[0m\n' "$*" >&2; }
mark_failed() { FAILED_TARGETS="${FAILED_TARGETS:+${FAILED_TARGETS} }$1"; }

# report_summary <report.xml>
# Prints 'tests=N failures=M errors=K', summed over the <testsuite> entries
# of a bats JUnit report (the top-level <testsuites> element carries no
# counts).
report_summary() {
  local report="$1"
  awk '
    match($0, /<testsuite [^>]*>/) {
      s = substr($0, RSTART, RLENGTH)
      if (match(s, /tests="[0-9]+"/))    t += substr(s, RSTART + 7, RLENGTH - 8)
      if (match(s, /failures="[0-9]+"/)) f += substr(s, RSTART + 10, RLENGTH - 11)
      if (match(s, /errors="[0-9]+"/))   e += substr(s, RSTART + 8, RLENGTH - 9)
    }
    END { printf "tests=%d failures=%d errors=%d", t, f, e }
  ' "${report}" 2>/dev/null || true
}

cleanup() {
  # Finalize the stored logs first (the most valuable artifacts): strip
  # the ANSI escape sequences the guest tools emit (make section titles,
  # brew/curl progress) so the logs read cleanly in any viewer -- naive
  # ones render the raw codes as literal "[92m" noise. cleanup runs from
  # the EXIT trap, so every exit path is covered.
  local log_file
  for log_file in "${UBUNTU_LOG}" "${MACOS_LOG}"; do
    if [ -f "${log_file}" ]; then
      LC_ALL=C sed $'s/\x1b\[[0-9;?]*[@-~]//g' "${log_file}" > "${log_file}.ansi.tmp" \
        && mv "${log_file}.ansi.tmp" "${log_file}"
    fi
  done
  # Always delete whatever VMs this run created, even on failure.
  if [ "${UBUNTU_VM_CREATED}" -eq 1 ]; then
    log "Deleting Ubuntu VM ${UBUNTU_VM}"
    multipass stop "${UBUNTU_VM}" >/dev/null 2>&1 || true
    # -p: permanently delete this instance only (bare `multipass purge` is
    # global and would wipe other deleted instances).
    multipass delete -p "${UBUNTU_VM}" >/dev/null 2>&1 || warn "failed to delete ${UBUNTU_VM}"
  fi
  if [ "${MACOS_VM_CREATED}" -eq 1 ]; then
    log "Deleting macOS VM ${MACOS_VM}"
    tart stop "${MACOS_VM}" >/dev/null 2>&1 || true
    if [ -n "${TART_RUN_PID}" ] && kill -0 "${TART_RUN_PID}" 2>/dev/null; then
      kill "${TART_RUN_PID}" >/dev/null 2>&1 || true
    fi
    tart delete "${MACOS_VM}" >/dev/null 2>&1 || warn "failed to delete ${MACOS_VM}"
  fi
}
trap cleanup EXIT

require_tools() {
  local missing="" tool
  for tool in "$@"; do
    command -v "$tool" >/dev/null 2>&1 || missing="${missing:+${missing} }${tool}"
  done
  if [ -n "${missing}" ]; then
    printf 'error: missing host tool(s): %s\n' "${missing}" >&2
    printf 'install them first: brew install --cask multipass; tart from the CirrusLabs release tarball (see README "Local e2e tests")\n' >&2
    exit 1
  fi
}

# --- guest-side scripts (plain text, executed inside the guest) -------------

# Env for every guest command that depends on installed tooling:
# dotbot ~/bin, pyenv/nodenv shims, the npm-global prefix, and both
# Homebrew prefixes (the absent one is a no-op, so this is OS-agnostic),
# plus deterministic Homebrew (no auto-update mid-run, no cleanup work).
# The $vars must stay literal: this export is expanded by the guest shell.
# shellcheck disable=SC2016
GUEST_PATH_EXPORT='export PATH="$HOME/bin:$HOME/.pyenv/shims:$HOME/.pyenv/bin:$HOME/.nodenv/shims:$HOME/.nodenv/bin:$HOME/.npm-global/bin:/opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:$PATH" HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1'

# Ubuntu guest setup (run as root): base tooling, the CPython build deps
# (pyenv compiles CPython from source), and bats (if missing).
setup_ubuntu_script="$(
  cat <<EOF
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \\
  git make zsh neovim curl ca-certificates \\
  build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \\
  libsqlite3-dev libffi-dev liblzma-dev
if ! command -v bats >/dev/null 2>&1; then
  curl -fsSL -o /tmp/bats.tar.gz \\
    "https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz"
  tar -xzf /tmp/bats.tar.gz -C /tmp
  /tmp/bats-core-${BATS_VERSION}/install.sh /usr/local
fi
bats --version
EOF
)"

# Install linuxbrew for the guest user (not root: the Homebrew installer
# refuses to run as root on Linux). NONINTERACTIVE=1 keeps it unattended.
homebrew_ubuntu_script="set -euo pipefail
export NONINTERACTIVE=1
export HOMEBREW_NO_AUTO_UPDATE=1
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  echo 'linuxbrew already present'
else
  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
fi
/home/linuxbrew/.linuxbrew/bin/brew --version"

# macOS guest setup (run as admin in a login shell, so brew is on PATH):
# verify the image ships brew and Xcode CLT, pre-install nodenv (so the
# in-`make setup` nodenv step only runs no-op updates), then install
# missing base tooling. The image's brew tap is intentionally NOT
# refreshed: the cirruslabs image ships a tap whose bottle set is proven
# for this macOS release, while the live tap can drift (a mid-run refresh
# can drop the guest to a no-bottles tier, forcing source builds that
# time out on external mirrors in-guest).
setup_macos_script="$(
  cat <<'EOF'
set -euo pipefail
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1
command -v brew >/dev/null 2>&1 || { echo "error: brew not found in guest"; exit 1; }
# CPython (pyenv) compiles from source, which needs make/cc. The base image
# may lack Xcode CLT; xcode-select --install is interactive, so surface the
# missing tools as a blocker instead of installing them silently.
command -v make >/dev/null 2>&1 && command -v cc >/dev/null 2>&1 || {
  echo "error: make/cc not found: Xcode Command Line Tools missing in guest"
  echo "error: install the CLT (e.g. 'xcode-select --install' from a GUI session) and re-run"
  exit 1
}
# nodenv-installer picks Homebrew when brew is on PATH. Satisfy it now, in
# isolation: afterwards its in-`make setup` branch only runs
# `brew update` + `brew upgrade nodenv`/`node-build` (no-op or a single
# bottle), never a multi-formula install.
brew install --quiet nodenv
if ! command -v nvim >/dev/null 2>&1; then brew install --quiet neovim; fi
if ! command -v bats >/dev/null 2>&1; then brew install --quiet bats-core; fi
bats --version
EOF
)"

# Run `make setup` non-interactively from the mounted repo.
install_ubuntu_script="set -euo pipefail
${GUEST_PATH_EXPORT}
cd \"${UBUNTU_GUEST_REPO}\"
make setup"

install_macos_script="set -euo pipefail
${GUEST_PATH_EXPORT}
cd \"${MACOS_GUEST_REPO}\"
make setup"

# Headless nvim plugin sync + :checkhealth export, immediately after
# `make setup`. Health warnings must not fail the run (|| true), but the
# report file must exist and be non-empty for the suite to assert on.
#
# The sync session must not exit while mason is installing: `qa!` during an
# install aborts every in-flight mason install (leaving the tools missing),
# and the follow-up :checkhealth re-triggers them through mason's lazy
# config, only to abort them a second time. The -c lua below polls until
# every expected tool has its install directory (mason only creates it when
# an install succeeds) or a 20-minute deadline passes, so :checkhealth runs
# against a fully provisioned guest. It logs progress every 30s, because
# mason is silent while downloading and a slow install would otherwise
# look like a hang. Mason's downloads have no total transfer timeout and
# no retries, so the wait also detects stalls (no new install for 5
# minutes), dumps the suspect processes, force-closes mason's stalled
# installs, and re-installs the missing tools (3 tries).
#
# MASON_TOOLS: what mason installs on a fresh config -- the
# ensure_installed list in nvim/lua/plugins/formatting.lua. Keep in sync
# with it.
MASON_TOOLS="$(
  sed -n '/ensure_installed = {/,/}/p' "${REPO_ROOT}/nvim/lua/plugins/formatting.lua" \
    | grep -oE '"[^"]+"' | tr -d '"' | awk 'NF && !seen[$0]++' || true
)"

nvim_health_script="set -euo pipefail
${GUEST_PATH_EXPORT}
export MASON_TOOLS='${MASON_TOOLS}'
nvim --headless \"+Lazy! sync\" -c \"lua vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })\" -c \"lua local _ = pcall(require, 'mason')
local raw = string.gsub(vim.env.MASON_TOOLS or '', '%s+', ' ')
local tools = vim.split(raw, ' ', { ignoreempty = true })
local deadline = os.time() + 1200
local started = os.time()
local STALL_SECS = 300
local MAX_RETRIES = 3
local attempts = {}
local last_change = { count = -1, time = os.time() }
local retry_pending = nil
local function installed_status()
  -- Fresh guest: mason.nvim may not be cloned (or configured) yet while
  -- Lazy! sync is still running; retry the require so its lazy config
  -- (registry refresh + installs of missing tools) is guaranteed to run.
  pcall(require, 'mason')
  local ok, reg = pcall(require, 'mason-registry')
  if not ok or not reg then
    return false, nil
  end
  -- mason creates a package install directory only when an install
  -- succeeds, so directory existence is a reliable completion signal.
  local missing = {}
  for _, name in ipairs(tools) do
    local okp, pkg = pcall(function() return reg.get_package(name) end)
    if not okp or not pkg or not pkg:is_installed() then
      missing[#missing + 1] = name
    end
  end
  return #missing == 0, missing
end
local timer = vim.uv.new_timer()
local polls = 0
local function finish(installed, missing)
  timer:stop()
  timer:close()
  if not installed then
    if missing == nil then
      io.stderr:write('error: mason-registry unavailable after ' .. (os.time() - started) .. 's; Lazy! sync may not have loaded plugins yet\\n')
    else
      io.stderr:write('error: mason install did not finish in time, still missing: ' .. table.concat(missing, ', ') .. '\\n')
    end
  end
  -- the timer callback runs in a fast event context, where vim.cmd is
  -- forbidden (E5560): defer the quit to the main loop.
  vim.schedule(function()
    vim.cmd('qa!')
  end)
end
-- mason spawns curl with only --connect-timeout (no total transfer
-- timeout) and never retries: a blackholed download hangs the install
-- forever (on fresh guests stylua has hit this repeatedly, always as
-- the first download started). The hung install also keeps its
-- installing state, so a plain re-install is refused; mason's
-- terminator force-closes every active install handle (SIGTERM, then
-- SIGKILL) through mason's own machinery, which marks the installs
-- failed and releases their slots.
local function stall_dump()
  -- the e2e log is the only post-mortem a deleted guest leaves: capture
  -- the suspect processes at each stall.
  local out = vim.fn.system('ps -eo pid=,ppid=,etime=,args=')
  for line in out:gmatch('[^\n]+') do
    if line:find('mason') or line:find('curl') or line:find('unzip') then
      io.stderr:write('mason wait: ps: ' .. line:sub(1, 300) .. '\\n')
    end
  end
end
local function retry_missing(missing, reason)
  for _, name in ipairs(missing) do
    local n = (attempts[name] or 0) + 1
    attempts[name] = n
    if n <= MAX_RETRIES then
      io.stderr:write(('mason wait: retry %d/%d for %s (%s)\\n'):format(n, MAX_RETRIES, name, reason))
      local tool = name
      vim.schedule(function()
        -- The MasonInstall user command quits nvim (1cq) on failure
        -- in headless mode; install through the registry API instead,
        -- which only marks the package failed.
        pcall(function()
          local reg = require('mason-registry')
          local okp, pkg = pcall(reg.get_package, tool)
          if okp and pkg and not pkg:is_installing() then
            pkg:install()
          end
        end)
      end)
    end
  end
end
local function poll()
  polls = polls + 1
  local done, missing = installed_status()
  if done then
    finish(true)
    return
  end
  if os.time() >= deadline then
    finish(false, missing)
    return
  end
  if retry_pending then
    retry_missing(retry_pending, 'stalled download')
    retry_pending = nil
  end
  local count = missing and (#tools - #missing) or nil
  if count and count ~= last_change.count then
    last_change = { count = count, time = os.time() }
  elseif missing and os.time() - last_change.time >= STALL_SECS then
    io.stderr:write(('mason wait: no progress for %ds; terminating stalled mason installs and retrying\\n'):format(os.time() - last_change.time))
    vim.schedule(function()
      stall_dump()
      pcall(function()
        require('mason-core.terminator').terminate(0)
      end)
    end)
    retry_pending = missing
    last_change = { count = count, time = os.time() }
  end
  -- keep the e2e log honest: mason is silent while downloading, so a
  -- multi-minute install would otherwise look like a hang.
  if polls % 10 == 0 then
    local elapsed = os.time() - started
    local msg
    if missing == nil then
      msg = 'mason wait: plugin not loaded yet (' .. elapsed .. 's elapsed)'
    else
      msg = 'mason wait: ' .. (#tools - #missing) .. '/' .. #tools
        .. ' installed, waiting for ' .. table.concat(missing, ', ')
        .. ' (' .. elapsed .. 's elapsed)'
    end
    io.stderr:write(msg .. '\\n')
  end
  timer:start(3000, 0, poll)
end
timer:start(3000, 0, poll)
\" || true
nvim --headless -c \"checkhealth\" -c \"w! /tmp/nvim-health.txt\" -c \"qa\" || true
[ -s /tmp/nvim-health.txt ] || { echo 'error: /tmp/nvim-health.txt missing or empty'; exit 1; }"

# Run the suite with the built-in JUnit formatter. The JUnit XML is the only
# stdout output; bats warnings go to /tmp/bats.stderr so the XML stays
# well-formed for the host-side report file.
test_ubuntu_script="set -e
cd \"${UBUNTU_GUEST_REPO}\"
bats --formatter junit tests/suite.bats 2> /tmp/bats.stderr"

test_macos_script="set -e
cd \"${MACOS_GUEST_REPO}\"
bats --formatter junit tests/suite.bats 2> /tmp/bats.stderr"

# --- phases ------------------------------------------------------------------

run_ubuntu() {
  local start status i guest_uid guest_gid
  start=$(date +%s)
  require_tools multipass

  : > "${UBUNTU_LOG}"
  rm -f "${UBUNTU_REPORT}" "${UBUNTU_HEALTH}"

  log "ubuntu: launching ${UBUNTU_RELEASE} VM ${UBUNTU_VM}"
  multipass stop "${UBUNTU_VM}" >/dev/null 2>&1 || true
  multipass delete -p "${UBUNTU_VM}" >/dev/null 2>&1 || true
  if ! multipass launch "${UBUNTU_RELEASE}" --name "${UBUNTU_VM}" --cpus 2 --memory 2G --disk 20G; then
    warn "ubuntu: multipass launch failed"
    mark_failed ubuntu
    return 0
  fi
  UBUNTU_VM_CREATED=1

  # multipass reports "Launched" before SSH is reliably reachable; wait
  # for the guest to answer exec, and capture its uid/gid for the mount
  # ownership map.
  log "ubuntu: waiting for the guest to come up"
  for i in $(seq 1 30); do
    if guest_uid=$(multipass exec "${UBUNTU_VM}" -- id -u 2>/dev/null) &&
      guest_gid=$(multipass exec "${UBUNTU_VM}" -- id -g 2>/dev/null); then
      break
    fi
    if [ "${i}" -eq 30 ]; then
      warn "ubuntu: guest did not come up within 2 minutes"
      mark_failed ubuntu
      return 0
    fi
    sleep 4
  done

  log "ubuntu: mounting repo at ${UBUNTU_GUEST_REPO}"
  if ! {
      echo "--- mounting repo ---"
      # guest_uid/guest_gid captured in the readiness wait above
      multipass exec "${UBUNTU_VM}" -- sudo mkdir -p "${UBUNTU_GUEST_REPO}"
      # Map host ownership to the guest user so git does not reject the
      # mounted repo as "dubious ownership".
      multipass mount -u "$(id -u):${guest_uid}" -g "$(id -g):${guest_gid}" \
        "${REPO_ROOT}" "${UBUNTU_VM}:${UBUNTU_GUEST_REPO}"
      multipass exec "${UBUNTU_VM}" -- test -f "${UBUNTU_GUEST_REPO}/install.sh"
    } 2>&1 | tee -a "${UBUNTU_LOG}"; then
    warn "ubuntu: repo mount failed"
    mark_failed ubuntu
    return 0
  fi

  # `make post-install` (and the nodenv installer) call sudo in the guest;
  # fail fast and loudly if it is not passwordless instead of working
  # around it.
  log "ubuntu: verifying passwordless sudo"
  if ! {
      echo "--- passwordless sudo check ---"
      multipass exec "${UBUNTU_VM}" -- sudo -n true
    } 2>&1 | tee -a "${UBUNTU_LOG}"; then
    warn "ubuntu: passwordless sudo unavailable; stopping (see ${UBUNTU_LOG})"
    mark_failed ubuntu
    return 0
  fi

  log "ubuntu: installing base tooling + CPython build deps (root)"
  if ! {
      echo "--- guest setup ---"
      multipass exec "${UBUNTU_VM}" -- sudo bash -c "${setup_ubuntu_script}"
    } 2>&1 | tee -a "${UBUNTU_LOG}"; then
    warn "ubuntu: base tooling install failed"
    mark_failed ubuntu
    return 0
  fi

  log "ubuntu: installing linuxbrew (guest user)"
  status=0
  {
    echo "--- linuxbrew install ---"
    multipass exec "${UBUNTU_VM}" -- bash -lc "${homebrew_ubuntu_script}"
  } 2>&1 | tee -a "${UBUNTU_LOG}" || status=$?
  if [ "${status}" -ne 0 ]; then
    warn "ubuntu: linuxbrew install failed (see ${UBUNTU_LOG})"
    mark_failed ubuntu
    return 0
  fi

  log "ubuntu: running make setup"
  status=0
  {
    echo "--- make setup ---"
    multipass exec "${UBUNTU_VM}" -- bash -lc "${install_ubuntu_script}"
  } 2>&1 | tee -a "${UBUNTU_LOG}" || status=$?
  if [ "${status}" -ne 0 ]; then
    warn "ubuntu: make setup failed (see ${UBUNTU_LOG})"
    mark_failed ubuntu
    return 0
  fi

  log "ubuntu: syncing neovim plugins headlessly + checkhealth"
  status=0
  {
    echo "--- nvim headless ---"
    multipass exec "${UBUNTU_VM}" -- bash -lc "${nvim_health_script}"
  } 2>&1 | tee -a "${UBUNTU_LOG}" || status=$?
  if [ "${status}" -ne 0 ]; then
    warn "ubuntu: headless neovim step failed (see ${UBUNTU_LOG})"
    mark_failed ubuntu
    return 0
  fi

  log "ubuntu: collecting nvim health report"
  status=0
  multipass exec "${UBUNTU_VM}" -- cat /tmp/nvim-health.txt \
    > "${UBUNTU_HEALTH}" 2>>"${UBUNTU_LOG}" || status=$?
  if [ "${status}" -ne 0 ] || [ ! -s "${UBUNTU_HEALTH}" ]; then
    warn "ubuntu: failed to collect the nvim health report"
    mark_failed ubuntu
    return 0
  fi

  log "ubuntu: running bats suite (junit)"
  if {
      multipass exec "${UBUNTU_VM}" -- bash -lc "${test_ubuntu_script}" | tee "${UBUNTU_REPORT}"
    } 2>&1; then
    {
      echo "--- bats stderr ---"
      multipass exec "${UBUNTU_VM}" -- cat /tmp/bats.stderr 2>/dev/null || true
    } >> "${UBUNTU_LOG}"
    log "ubuntu: PASS ($(report_summary "${UBUNTU_REPORT}")) [$(($(date +%s) - start))s]"
  else
    {
      echo "--- bats stderr ---"
      multipass exec "${UBUNTU_VM}" -- cat /tmp/bats.stderr 2>/dev/null || true
    } >> "${UBUNTU_LOG}"
    warn "ubuntu: bats suite failed (see ${UBUNTU_REPORT})"
    mark_failed ubuntu
  fi
  return 0
}

run_macos() {
  local start status i
  start=$(date +%s)
  require_tools tart

  : > "${MACOS_LOG}"
  rm -f "${MACOS_REPORT}" "${MACOS_HEALTH}"

  log "macos: cloning ${MACOS_IMAGE} -> ${MACOS_VM}"
  tart stop "${MACOS_VM}" >/dev/null 2>&1 || true
  tart delete "${MACOS_VM}" >/dev/null 2>&1 || true
  if ! tart clone "${MACOS_IMAGE}" "${MACOS_VM}" 2>&1 | tee -a "${MACOS_LOG}"; then
    warn "macos: tart clone failed (first run downloads the image)"
    mark_failed macos
    return 0
  fi
  MACOS_VM_CREATED=1
  tart set "${MACOS_VM}" --memory 6144

  log "macos: starting VM with repo shared as 'dotfiles'"
  # tart run is foreground-only: it stays attached for the VM's whole
  # lifetime, so launch it in the background and drive the guest via
  # tart exec.
  tart run --no-graphics --dir="dotfiles:${REPO_ROOT}" "${MACOS_VM}" \
    >>"${MACOS_LOG}" 2>&1 &
  TART_RUN_PID=$!

  log "macos: waiting for the guest agent to come up"
  for i in $(seq 1 90); do
    if tart exec "${MACOS_VM}" /usr/bin/true 2>/dev/null; then
      break
    fi
    if ! kill -0 "${TART_RUN_PID}" 2>/dev/null; then
      warn "macos: tart run died (see ${MACOS_LOG})"
      mark_failed macos
      return 0
    fi
    if [ "${i}" -eq 90 ]; then
      warn "macos: guest agent did not come up within 6 minutes"
      mark_failed macos
      return 0
    fi
    sleep 4
  done

  # tart exposes shared directories at /Volumes/My Shared Files/<name>;
  # alias them to /Volumes/dotfiles so the install path is stable. The
  # sudo -n here also proves the guest has passwordless sudo (the Makefile
  # uses sudo in the nodenv installer and post-install).
  log "macos: exposing the shared repo at ${MACOS_GUEST_REPO}"
  status=0
  {
    echo "--- mounting repo ---"
    tart exec "${MACOS_VM}" /usr/bin/sudo -n /bin/bash -c '
      set -euo pipefail
      if [ -d "/Volumes/My Shared Files/dotfiles" ] && [ ! -e /Volumes/dotfiles ]; then
        ln -s "/Volumes/My Shared Files/dotfiles" /Volumes/dotfiles
      fi
      test -f /Volumes/dotfiles/install.sh
    '
  } 2>&1 | tee -a "${MACOS_LOG}" || status=$?
  if [ "${status}" -ne 0 ]; then
    warn "macos: repo not visible at ${MACOS_GUEST_REPO}"
    mark_failed macos
    return 0
  fi

  log "macos: verifying guest prerequisites (brew, Xcode CLT) + base tooling"
  status=0
  {
    echo "--- guest setup ---"
    tart exec "${MACOS_VM}" /usr/bin/sudo -n -u admin /bin/bash -lc "${setup_macos_script}"
  } 2>&1 | tee -a "${MACOS_LOG}" || status=$?
  if [ "${status}" -ne 0 ]; then
    warn "macos: guest prerequisites failed (see ${MACOS_LOG})"
    mark_failed macos
    return 0
  fi

  log "macos: running make setup"
  status=0
  {
    echo "--- make setup ---"
    tart exec "${MACOS_VM}" /usr/bin/sudo -n -u admin /bin/bash -lc "${install_macos_script}"
  } 2>&1 | tee -a "${MACOS_LOG}" || status=$?
  if [ "${status}" -ne 0 ]; then
    warn "macos: make setup failed (see ${MACOS_LOG})"
    mark_failed macos
    return 0
  fi

  log "macos: syncing neovim plugins headlessly + checkhealth"
  status=0
  {
    echo "--- nvim headless ---"
    tart exec "${MACOS_VM}" /usr/bin/sudo -n -u admin /bin/bash -lc "${nvim_health_script}"
  } 2>&1 | tee -a "${MACOS_LOG}" || status=$?
  if [ "${status}" -ne 0 ]; then
    warn "macos: headless neovim step failed (see ${MACOS_LOG})"
    mark_failed macos
    return 0
  fi

  log "macos: collecting nvim health report"
  status=0
  tart exec "${MACOS_VM}" /bin/cat /tmp/nvim-health.txt \
    > "${MACOS_HEALTH}" 2>>"${MACOS_LOG}" || status=$?
  if [ "${status}" -ne 0 ] || [ ! -s "${MACOS_HEALTH}" ]; then
    warn "macos: failed to collect the nvim health report"
    mark_failed macos
    return 0
  fi

  log "macos: running bats suite (junit)"
  if {
      tart exec "${MACOS_VM}" /usr/bin/sudo -n -u admin /bin/bash -lc "${test_macos_script}" | tee "${MACOS_REPORT}"
    } 2>&1; then
    {
      echo "--- bats stderr ---"
      tart exec "${MACOS_VM}" /usr/bin/sudo -n -u admin /bin/bash -c 'cat /tmp/bats.stderr 2>/dev/null' || true
    } >> "${MACOS_LOG}"
    log "macos: PASS ($(report_summary "${MACOS_REPORT}")) [$(($(date +%s) - start))s]"
  else
    {
      echo "--- bats stderr ---"
      tart exec "${MACOS_VM}" /usr/bin/sudo -n -u admin /bin/bash -c 'cat /tmp/bats.stderr 2>/dev/null' || true
    } >> "${MACOS_LOG}"
    warn "macos: bats suite failed (see ${MACOS_REPORT})"
    mark_failed macos
  fi
  return 0
}

main() {
  local target="${1:-all}"
  case "${target}" in
    ubuntu | macos | all) ;;
    *)
      printf 'usage: %s [ubuntu|macos|all]\n' "$0" >&2
      exit 1
      ;;
  esac

  mkdir -p "${RESULTS_DIR}"

  case "${target}" in
    ubuntu) run_ubuntu ;;
    macos) run_macos ;;
    all) run_ubuntu; run_macos ;;
  esac

  if [ -n "${FAILED_TARGETS}" ]; then
    printf '\n\033[1;31mFAIL: %s\033[0m\n' "${FAILED_TARGETS}"
    printf 'reports and logs: %s\n' "${RESULTS_DIR}"
    exit 1
  fi
  printf '\n\033[1;32mPASS: all requested target(s): %s\033[0m\n' "${target}"
  printf 'reports and logs: %s\n' "${RESULTS_DIR}"
}

main "$@"
