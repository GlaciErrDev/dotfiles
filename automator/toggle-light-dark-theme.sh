#!/bin/sh
# Toggle the light/dark theme: macOS appearance + tmux, nvim, bat, yazi, btop.
# Target state is derived from the current macOS appearance, so re-running is a no-op.

set -u

# Hotkey/Automator invocations get a bare PATH; cover both brew prefixes.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Follow symlinks to the real file, so in-place edits land in the dotfiles repo
# and never replace a dotbot-managed symlink with a plain file.
resolve() {
  p=$1
  while [ -L "$p" ]; do
    t=$(readlink "$p")
    case $t in /*) ;; *) t=$(dirname "$p")/$t ;; esac
    p=$t
  done
  printf '%s' "$p"
}

# In-place sed with no backup file; the empty '' suffix is explicit so the next
# flag (-E) is never mistaken for a backup suffix by BSD or GNU sed.
sedconf() { # sedconf <path> <script>
  f=$(resolve "$1")
  [ -f "$f" ] && sed -i '' -E -e "$2" "$f"
}

DARK=$(osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode.get()")

if [ "$DARK" = "true" ]; then
  MODE=LIGHT NEXT_DARK=false
  TMUX_VARIANT="day"; NVIM_BG="light"; TN_STYLE="day"
  BAT_LINE='--theme="Catppuccin Latte"'
  YAZI_LINE='use = "catppuccin-latte"'
  BTOP_THEME="$HOME/.config/btop/themes/catppuccin_latte.theme"
else
  MODE=DARK NEXT_DARK=true
  TMUX_VARIANT="night"; NVIM_BG="dark"; TN_STYLE="night"
  BAT_LINE='--theme="Catppuccin Mocha"'
  YAZI_LINE='use = "catppuccin-mocha"'
  BTOP_THEME="$HOME/.config/btop/themes/catppuccin_mocha.theme"
fi

# tmux: rewrite the variant, reload if a server is running
sedconf "$HOME/.tmux.conf" \
  "s|^set -g @powerkit_theme_variant \"[^\"]*\"$|set -g @powerkit_theme_variant \"$TMUX_VARIANT\"|"
tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true

# Running nvim panes: tokyonight has no background-change hook, so apply it explicitly
tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null |
  awk '$2 == "nvim" || $2 == "vim" { print $1 }' |
  while IFS= read -r pane; do
    tmux send-keys -t "$pane" ESCAPE ":lua require(\"tokyonight\").load({ style = \"$TN_STYLE\" })" ENTER 2>/dev/null || true
  done

# Persistent configs, picked up on next start
sedconf "$HOME/.config/nvim/lua/config/options.lua" \
  "s|opt.background = \"[a-z]*\"|opt.background = \"$NVIM_BG\"|"
sedconf "$HOME/.config/nvim/lua/plugins/colorscheme.lua" \
  "s|^([[:space:]]*)style = \"[a-z]*\",|\1style = \"$TN_STYLE\",|"
sedconf "$HOME/.config/bat/config" "s|^--theme=.*$|$BAT_LINE|"
sedconf "$HOME/.config/yazi/theme.toml" "s|^use = \".*\"$|$YAZI_LINE|"
sedconf "$HOME/.config/btop/btop.conf" "s|^color_theme = \".*\"$|color_theme = \"$BTOP_THEME\"|"

# Running btop: reload its config (quiet no-op if not running)
pkill -s USR2 -x btop || true

# Flip the system appearance last, so the desktop and terminal themes land together
osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode.set($NEXT_DARK)" >/dev/null 2>&1

echo "$MODE"
