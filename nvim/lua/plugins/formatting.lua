return {
  {
    "mason-org/mason.nvim",
    event = { "VeryLazy" },
    config = function()
      require("mason").setup({})
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = { "VeryLazy" },
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      -- Keep in sync with MASON_TOOLS in scripts/test-e2e.sh.
      ensure_installed = {
        "pyright",
        "gopls",
        "lua-language-server",
        "ruff",
        "stylua",
        "gofumpt",
        "goimports",
        "staticcheck",
      },
      run_on_start = true,
    },
  },
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ lsp_fallback = true, async = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    cmd = { "ConformInfo" },
    opts = {
      -- Format on save, falling back to the attached LSP's formatter.
      format_on_save = { lsp_fallback = true },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff" },
        go = { "goimports", "gofumpt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost" },
    cmd = { "Lint", "LintInfo" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        go = { "staticcheck" },
      }
      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
          lint.lint()
        end,
      })
    end,
  },
}
