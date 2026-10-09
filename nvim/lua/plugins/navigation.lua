return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
      {
        "<leader>fr",
        function()
          require("fzf-lua").lsp_references()
        end,
        desc = "LSP references",
      },
      { "<leader>fs", "<cmd>FzfLua search_history<CR>", desc = "Search history" },
      { "<leader>gL", "<cmd>FzfLua git_log<CR>", desc = "Git Log (cwd)" },
      {
        "<leader>gl",
        function()
          local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
          if root and root ~= "" then
            require("fzf-lua").git_log({ cwd = root })
          else
            vim.notify("Not a git repository", vim.log.levels.WARN)
          end
        end,
        desc = "Git Log",
      },
      { "<leader>gf", "<cmd>FzfLua git_log_file<CR>", desc = "Git Current File History" },
    },
    opts = {
      files = { cwd = vim.fn.getcwd() },
      -- Pin live_grep to ripgrep (fzf-lua auto-detects via PATH; a
      -- session without rg in PATH would silently fall back to grep).
      grep = {
        cmd = (vim.fn.executable("rg") == 1 and vim.fn.exepath("rg") or "rg")
            .. " --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
      },
    },
  },
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
    "stevearc/oil.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        mode = "n",
        desc = "Oil file manager",
      },
      {
        "<leader>e",
        function()
          require("oil").toggle_float()
        end,
        mode = "n",
        desc = "Oil parent dir (float)",
      },
    },
    opts = {
      columns = { "icon" },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-k>"] = false,
        ["<C-j>"] = false,
        ["<M-h>"] = "actions.select_split",
      },
      view_options = {
        show_hidden = true,
      },
      -- Configuration for the floating window in oil.open_float
      float = {
        max_width = 100,
        max_height = 40,
      },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
    },
  },
  {
    "nvim-focus/focus.nvim",
    cmd = { "FocusClear", "FocusToggle", "FocusMaximize" },
    config = function()
      require("focus").setup({})
    end,
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
