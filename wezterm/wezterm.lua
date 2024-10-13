local wezterm = require("wezterm")

function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Catppuccin Mocha"
  else
    return "Catppuccin Mocha"
  end
end

return {
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  font = wezterm.font("Hack Nerd Font"),
  font_size = 15.5,
  initial_rows = 80,
  initial_cols = 160,
  -- Removes the macos bar at the top with the 3 buttons
  window_decorations = "RESIZE",
  enable_tab_bar = false,
  cursor_blink_ease_out = "Constant",
  cursor_blink_ease_in = "Constant",
  cursor_blink_rate = 400,

  window_padding = {
    left = 2,
    right = 2,
    top = 15,
    bottom = 0,
  },
}
