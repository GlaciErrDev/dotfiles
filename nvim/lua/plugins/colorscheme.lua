return {
  {
    "catppuccin",
    opts = {
      transparent_background = true,
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "day",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "catppuccin",
      colorscheme = "tokyonight",
    },
  },
}
