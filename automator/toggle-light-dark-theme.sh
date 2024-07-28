export PATH=/opt/homebrew/bin:$PATH

# By default, would be applied DARK theme
PREV_ALACRITTY_THEME="catppuccin-latte"
NEXT_ALACRITTY_THEME="catppuccin-mocha"
PREV_TMUX_THEME="latte"
NEXT_TMUX_THEME="mocha"
PREV_NVIM_THEME="light"
NEXT_NVIM_THEME="dark"
PREV_BAT_THEME="Latte"
NEXT_BAT_THEME="Mocha"
PREV_DELTA_THEME="catppuccin-latte"
NEXT_DELTA_THEME="catppuccin-mocha"
APPLIED_THEME="DARK"

# Check if Dark theme was applied
DARK_MODE=$(osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode.get()")
if $DARK_MODE; then
  PREV_ALACRITTY_THEME="catppuccin-mocha"
  NEXT_ALACRITTY_THEME="catppuccin-latte"
  PREV_TMUX_THEME="mocha"
  NEXT_TMUX_THEME="latte"
  PREV_NVIM_THEME="dark"
  NEXT_NVIM_THEME="light"
  PREV_BAT_THEME="Mocha"
  NEXT_BAT_THEME="Latte"
  PREV_DELTA_THEME="catppuccin-mocha"
  NEXT_DELTA_THEME="catppuccin-latte"
  APPLIED_THEME="LIGHT"
fi

# change macos theme
osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode.set(!$DARK_MODE)" >/dev/null 2>&1
# change alacritty theme
sed -i -e "s/$PREV_ALACRITTY_THEME/$NEXT_ALACRITTY_THEME/" ~/.config/alacritty/alacritty.toml
# change tmux theme
sed "s/$PREV_TMUX_THEME/$NEXT_TMUX_THEME/g" <$HOME/.tmux.conf 1<>$HOME/.tmux.conf
# reload tmux config
tmux source-file ~/.tmux.conf
# using tmux to find panes with nvim sessions and then change their background
tmux list-panes -a -F '#{pane_id} #{pane_current_command}' | grep vim | cut -d ' ' -f 1 | xargs -I PANE tmux send-keys -t PANE ESCAPE ":set background=$NEXT_NVIM_THEME" ENTER
# permanently changes background mode
sed -i -e "s/$PREV_NVIM_THEME/$NEXT_NVIM_THEME/" ~/.config/nvim/lua/config/options.lua
# change bat theme
sed -i -e "s/$PREV_BAT_THEME/$NEXT_BAT_THEME/" ~/.config/bat/config
# change delta theme
sed "s/$PREV_DELTA_THEME/$NEXT_DELTA_THEME/g" <$HOME/.gitconfig 1<>$HOME/.gitconfig
# notification message
echo $APPLIED_THEME
