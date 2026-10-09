return {
  {
    "folke/flash.nvim",
    -- Stock config: search mode stays off and char mode (f/t/;) works
    -- as-is; flash 1.x sets no jump keymap itself, so map `s` to
    -- Flash.jump per the README.
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
    },
    config = true,
  },
  {
    "s1n7ax/nvim-window-picker",
    keys = {
      {
        "<leader>wj",
        function()
          local picked = require("window-picker").pick_window()
          vim.api.nvim_set_current_win(picked)
        end,
        desc = "WindowPicker",
      },
    },
    cmd = "WindowPicker",
    config = function()
      require("window-picker").setup({})
    end,
  },
  {
    "folke/which-key.nvim",
    event = { "VeryLazy" },
    opts = {
      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Help" },
        { "<leader>s", group = "Search" },
        { "<leader>u", group = "UI" },
        { "<leader>w", group = "Window" },
        { "<leader>x", group = "List" },
      },
    },
  },
}
