tmp=$(mktemp)

export PATH=/opt/homebrew/bin:$PATH

CATPPUCCIN_LATTE_2="latte"
CATPPUCCIN_MOCHA_2="mocha"

CATPPUCCIN_LATTE_3="Latte"
CATPPUCCIN_MOCHA_3="Mocha"

BTOP_CATPPUCCIN_LATTE="$HOME/.config/btop/themes/catppuccin_latte.theme"
BTOP_CATPPUCCIN_MOCHA="$HOME/.config/btop/themes/catppuccin_mocha.theme"

NVIM_LIGHT="light"
NVIM_DARK="dark"

TOKYONIGHT_DAY="day"
TOKYONIGHT_NIGHT="night"

PREV_TMUX_THEME=$TOKYONIGHT_DAY
NEXT_TMUX_THEME=$TOKYONIGHT_NIGHT
PREV_NVIM_THEME=$NVIM_LIGHT
NEXT_NVIM_THEME=$NVIM_DARK
PREV_NVIM_TOKYONIGHT_STYLE=$TOKYONIGHT_DAY
NEXT_NVIM_TOKYONIGHT_STYLE=$TOKYONIGHT_NIGHT
PREV_BAT_THEME=$CATPPUCCIN_LATTE_3
NEXT_BAT_THEME=$CATPPUCCIN_MOCHA_3
PREV_YAZI_THEME=$CATPPUCCIN_LATTE_2
NEXT_YAZI_THEME=$CATPPUCCIN_MOCHA_2
NEXT_BTOP_THEME=$BTOP_CATPPUCCIN_MOCHA
APPLIED_THEME="DARK"

# Check if Dark theme was applied
DARK_MODE=$(osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode.get()")
if $DARK_MODE; then
  PREV_TMUX_THEME=$TOKYONIGHT_NIGHT
  NEXT_TMUX_THEME=$TOKYONIGHT_DAY
  PREV_NVIM_THEME=$NVIM_DARK
  NEXT_NVIM_THEME=$NVIM_LIGHT
  PREV_NVIM_TOKYONIGHT_STYLE=$TOKYONIGHT_NIGHT
  NEXT_NVIM_TOKYONIGHT_STYLE=$TOKYONIGHT_DAY
  PREV_BAT_THEME=$CATPPUCCIN_MOCHA_3
  NEXT_BAT_THEME=$CATPPUCCIN_LATTE_3
  PREV_YAZI_THEME=$CATPPUCCIN_MOCHA_2
  NEXT_YAZI_THEME=$CATPPUCCIN_LATTE_2
  NEXT_BTOP_THEME=$BTOP_CATPPUCCIN_LATTE
  APPLIED_THEME="LIGHT"
fi

# change tmux theme
sed "s/set -g @powerkit_theme_variant \"$PREV_TMUX_THEME\"/set -g @powerkit_theme_variant \"$NEXT_TMUX_THEME\"/g" "$HOME/.tmux.conf" >"$tmp" && mv "$tmp" "$HOME/.tmux.conf"
# reload tmux config
tmux source-file ~/.tmux.conf
# using tmux to find panes with nvim sessions and then change their background
tmux list-panes -a -F '#{pane_id} #{pane_current_command}' | grep vim | cut -d ' ' -f 1 | xargs -I PANE tmux send-keys -t PANE ESCAPE ":set background=$NEXT_NVIM_THEME" ENTER
# permanently changes background mode
sed -i -e "s/$PREV_NVIM_THEME/$NEXT_NVIM_THEME/" $HOME/.config/nvim/lua/config/options.lua
# change nvim tokyonight theme style
sed -i -e "s/style = \"$PREV_NVIM_TOKYONIGHT_STYLE\",/style = \"$NEXT_NVIM_TOKYONIGHT_STYLE\",/" $HOME/.config/nvim/lua/plugins/colorscheme.lua
# change bat theme
sed -i -e "s/$PREV_BAT_THEME/$NEXT_BAT_THEME/" $HOME/.config/bat/config
# change btop theme
sed -i -E 's|\(^color_theme = \"\).*\(\"$\)|\1'$NEXT_BTOP_THEME'\2|' $HOME/.config/btop/btop.conf
# send the USR2 signal to the process to make it reload the configuration from disk
ps aux | grep btop | awk '{print $11 " " $2}' | grep btop | awk '{print $2}' | xargs kill -s USR2
# change macos theme
osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode.set(!$DARK_MODE)" >/dev/null 2>&1
# change yazi theme
sed -i -e "s/$PREV_YAZI_THEME/$NEXT_YAZI_THEME/" $HOME/.config/yazi/theme.toml
# notification message
echo $APPLIED_THEME
