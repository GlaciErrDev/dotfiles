show_available_space() {
  local index icon color text module

  index=$1
  icon=$(get_tmux_option "@catppuccin_available_space_icon" "")
  color=$(get_tmux_option "@catppuccin_available_space_color" "$thm_blue")
  text=$(get_tmux_option "@catppuccin_available_space_text" "#{df_avail}")
  module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo "$module"
}
