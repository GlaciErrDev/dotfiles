return {
  {
    "echasnovski/mini.icons",
    lazy = false,
    priority = 1000,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 990,
    config = function()
      require("tokyonight").setup({
        style = "moon",
        terminal_colors = true,
      })
      vim.cmd.colorscheme("tokyonight")
      -- Let the terminal's own background show through (Ghostty runs
      -- with background-opacity < 1; a solid Normal bg would hide it).
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = { "VeryLazy" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        icon_separator = "none",
        component_separator = "│",
        section_separator = "",
      },
      sections = {
        lualine_a = { "branch", "diagnostics" },
        lualine_b = { "filename" },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
  {
    "folke/noice.nvim",
    event = { "VeryLazy" },
    dependencies = { "MunifTanjim/nui.nvim" },
    -- cmdline, messages and menus get the noice UI; lualine keeps the
    -- statusline (noice's own statusline module stays disabled).
    config = true,
  },
  {
    "NStefan002/screenkey.nvim",
    -- Eager (like the old config): the VimEnter autostart below only
    -- works if the :Screenkey command exists at startup, which a lazy
    -- keys trigger would miss.
    lazy = false,
    keys = {
      { "<leader>u", function()
        require("screenkey").toggle()
      end, desc = "Toggle keycast" },
    },
    config = function()
      require("screenkey").setup({})
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("AutostartScreenkey", {}),
        command = "Screenkey toggle",
      })
    end,
  },
}
