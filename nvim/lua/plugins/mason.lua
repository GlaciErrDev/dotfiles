return {
  -- add any tools you want to have installed below. Do NOT list stylua or
  -- shfmt here: LazyVim's own ensure_installed defaults already include
  -- both, the two lists are concatenated without dedup (opts_extend), and
  -- mason asserts on a duplicated entry ("Package is already installing").
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "black",
        "flake8",
        "gofumpt",
        "goimports",
        "goimports-reviser",
        "golangci-lint",
        "gopls",
        "json-lsp",
        "lua-language-server",
        "mypy",
        "pyright",
        "shellcheck",
      },
    },
  },
  { "mason-org/mason-lspconfig.nvim" },
}
