return {
  -- add any tools you want to have installed below
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
        "shfmt",
        "stylua",
      },
      automatic_installation = true,
    },
  },
  { "mason-org/mason-lspconfig.nvim" },
}
