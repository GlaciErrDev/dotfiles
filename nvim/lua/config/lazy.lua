-- Bootstrap lazy.nvim and start it with the specs in lua/plugins/.
-- The whole tree is imported recursively, including plugins/lang/.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup("plugins", {
  install = {
    colorscheme = { "tokyonight" },
    timeout = 600,
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = { notify = false },
  defaults = {
    -- Most plugins have no useful git tags; always track latest commits.
    version = false,
  },
  performance = {
    rtp = {
      -- Built-ins that are superseded by plugins or never used.
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarplugin",
        "tclplugin",
        "tohtml",
        "vimball",
        "zipplugin",
        "rplugin",
        "spellfile",
        "imapfile",
        "optwin",
        "runvial",
        "toftplugin",
      },
    },
  },
})
