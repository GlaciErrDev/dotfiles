-- nvim-lspconfig provides the built-in server defaults that
-- vim.lsp.config()/vim.lsp.enable() merge with (see lua/config/lsp.lua
-- for the per-server registration). Must be loaded on BufReadPre/
-- BufNewFile (the LazyVim starter uses exactly this): the enable
-- autocmd fires on FileType, which for a startup file happens before
-- VeryLazy — with lspconfig not yet on the rtp the merged config has
-- no `cmd` and the server logs "invalid config ... got nil" and never
-- starts for the buffer.
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
  },
}
