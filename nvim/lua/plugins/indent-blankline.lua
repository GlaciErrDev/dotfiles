return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "▏",
        tab_char = "▏",
        -- char = "▎",
        -- tab_char = "▎",
      },
      scope = {
        enabled = true,
        -- char = "▎",
        char = "▍",
        show_start = false,
      },
      whitespace = {
        remove_blankline_trail = true,
      },
    },
  },
}
