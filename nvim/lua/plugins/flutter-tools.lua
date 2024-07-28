return {
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    opts = function()
      return {
        debugger = {
          enabled = false,
          run_via_dap = false,
          exception_breakpoints = {},
        },
        outline = { auto_open = false },
        widget_guides = { enabled = true, debug = false },
        dev_log = { enabled = true, open_cmd = "tabedit" },
        lsp = {
          color = {
            enabled = true,
            background = true,
            virtual_text = false,
          },
          settings = {
            analysisExcludedFolders = {
              vim.fn.expand("$HOME/.pub-cache"),
              -- vim.fn.expand '$HOME/fvm/versions', -- flutter-tools should automatically exclude your SDK.
              vim.fn.expand("$HOME/tools/flutter"),
              vim.fn.expand("/opt/homebrew/"),
              vim.fn.expand("$HOME/Library/Application Support/"),
            },
            showTodos = false,
            renameFilesWithClasses = "always",
            updateImportsOnRename = true,
            completeFunctionCalls = true,
            lineLength = 100,
          },
        },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
  },
}
