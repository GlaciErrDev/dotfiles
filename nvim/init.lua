-- Vanilla Neovim config entry point.
--
-- Layout:
--   init.lua             this file
--   lua/config/          core: options, autocmds, keymaps, lsp, lazy bootstrap
--   lua/plugins/         lazy.nvim specs (lang/ holds the per-language bundles)
--   after/ftplugin/      per-filetype option overrides

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.lsp")

require("config.lazy")
