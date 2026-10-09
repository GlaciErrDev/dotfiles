return {
  {
    "echasnovski/mini.ai",
    keys = {
      { "a", mode = "o", desc = "Add object" },
      { "i", mode = "o", desc = "Inner object" },
    },
    config = true,
    -- The LazyVim textobject set (lua/lazyvim/plugins/coding.lua).
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" },
          e = {
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = function(ai_type)
            -- buffer object (LazyVim.mini.ai_buffer)
            local start_line, end_line = 1, vim.fn.line("$")
            if ai_type == "i" then
              local first_nonblank = vim.fn.nextnonblank(start_line)
              local last_nonblank = vim.fn.prevnonblank(end_line)
              if first_nonblank == 0 or last_nonblank == 0 then
                return { from = { line = start_line, col = 1 } }
              end
              start_line, end_line = first_nonblank, last_nonblank
            end
            local to_col = math.max(vim.fn.getline(end_line):len(), 1)
            return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
          end,
          u = ai.gen_spec.function_call(),
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      }
    end,
  },
  {
    "echasnovski/mini.comment",
    keys = {
      { "gcc", mode = "n", desc = "Toggle comment" },
      { "gc", mode = { "n", "v" }, desc = "Comment" },
      { "gc", mode = "o", desc = "Comment" },
    },
    config = true,
  },
  {
    "echasnovski/mini.pairs",
    event = { "InsertEnter" },
    keys = {
      {
        "<leader>up",
        function()
          vim.g.minipairs_disable = not vim.g.minipairs_disable
        end,
        desc = "Toggle Auto Pairs",
      },
    },
    config = true,
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is a closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
  },
  {
    "echasnovski/mini.surround",
    keys = {
      { "sa", mode = "n", desc = "Add surround" },
      { "sd", mode = "n", desc = "Delete surround" },
      { "sr", mode = "n", desc = "Replace surround" },
    },
    config = true,
  },
  {
    "monaqa/dial.nvim",
    -- dial defines <Plug> targets but ships no keymaps of its own.
    -- Load at VeryLazy (not on first keypress): the lazy key-trigger
    -- re-feed can drop the first <C-a>/<C-x> press, which made the
    -- increment look broken until the plugin happened to be loaded.
    event = { "VeryLazy" },
    keys = {
      { "<C-a>", mode = { "n", "v" }, desc = "Increment" },
      { "<C-x>", mode = { "n", "v" }, desc = "Decrement" },
    },
    config = function()
      local map = vim.keymap.set
      map("n", "<C-a>", "<Plug>(dial-increment)", { desc = "Increment" })
      map("n", "<C-x>", "<Plug>(dial-decrement)", { desc = "Decrement" })
      map("v", "<C-a>", "<Plug>(dial-increment)", { desc = "Increment" })
      map("v", "<C-x>", "<Plug>(dial-decrement)", { desc = "Decrement" })
    end,
  },
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", "<cmd>GrugFar<CR>", desc = "Search and replace" },
    },
  },
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost" },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
    opts = { delay = 200 },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "VeryLazy" },
    config = true,
    opts = { signs = true },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next TODO",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_previous()
        end,
        desc = "Previous TODO",
      },
      {
        "<leader>ft",
        function()
          require("fzf-lua").todo()
        end,
        desc = "Find TODOs",
      },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    event = { "LspAttach" },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      -- nvim 0.12 only: refactoring.nvim falls back to async.nvim when
      -- the native vim.async module (0.13+) is unavailable.
      "lewis6991/async.nvim",
    },
    -- Current refactoring.nvim creates no keymaps itself (README:
    -- "no keymaps are created by default") and the old `keymaps`,
    -- `auto_import` and `auto_create_roots` opts no longer exist —
    -- wire the maps per the README instead (expr, operator-pending).
    config = function()
      local map = vim.keymap.set
      map({ "n", "x" }, "<leader>re", function()
        return require("refactoring").extract_func()
      end, { desc = "Extract Function", expr = true })
      map({ "n", "x" }, "<leader>rz", function()
        return require("refactoring").extract_func_to_file()
      end, { desc = "Extract Function to File", expr = true })
      map({ "n", "x" }, "<leader>rf", function()
        return require("refactoring").inline_var()
      end, { desc = "Inline Variable", expr = true })
      map({ "n", "x" }, "<leader>rr", function()
        vim.lsp.buf.rename()
      end, { desc = "Rename (LSP)" })
    end,
  },
}
