-- Global options. Per-filetype overrides live in after/ftplugin/.

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.mouse = "a"
opt.laststatus = 3
opt.showmode = false
opt.showcmd = false
opt.ruler = false
opt.scrolloff = 8
opt.sidescrolloff = 10
opt.pumheight = 10
opt.completeopt = { "menu", "menuone", "noselect" }
opt.fillchars = { eob = " " }
opt.splitright = true
opt.splitbelow = true
opt.wrap = false
opt.linebreak = true
opt.emoji = true

-- Editing
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.inccommand = "split"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.undolevels = 10000

-- Files
opt.backup = false
opt.swapfile = false
opt.writebackup = false
opt.history = 1000

-- Timing
opt.updatetime = 250
opt.timeoutlen = 400

-- Environment
-- Mason-installed tools (LSP servers, conform formatters) resolve by
-- bare command name; make sure mason's bin dir is on PATH regardless of
-- how nvim was launched (LazyVim's mason-lspconfig used to supply
-- absolute paths, so the gap only showed up after the migration).
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 and not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end
