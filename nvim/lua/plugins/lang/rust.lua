-- Rust: rustaceanvim owns rust-analyzer (do NOT configure rust_analyzer
-- through nvim-lspconfig; recent rustaceanvim is a filetype plugin that
-- initializes itself and configures the client from vim.g.rustaceanvim).
-- crates.nvim adds Cargo.toml dependency completions.
--
-- rust-analyzer itself comes from the system Rust toolchain (rustup).
return {
  {
    "mrcjkb/rustaceanvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
      vim.g.rustaceanvim = opts
    end,
    opts = {
      server = {
        -- Merged over rustaceanvim's environment-aware defaults.
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              loadOutDirsFromCheckConfig = true,
              allFeatures = true,
            },
            check = { command = "clippy" },
          },
        },
      },
    },
  },
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    config = true,
    opts = {
      completion = { cmp = { enabled = true } },
    },
  },
}
