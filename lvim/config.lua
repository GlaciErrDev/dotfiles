--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "newpaper"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"


require("nvim-tree").setup({
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true
  },
})

lvim.builtin.which_key.mappings["l"]["f"] = {
  function()
    require("lvim.lsp.utils").format { timeout_ms = 5000 }
  end,
  "Format",
}
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false
lvim.builtin.bufferline.options.always_show_bufferline = true
lvim.builtin.breadcrumbs.active = false
lvim.builtin.nvimtree.setup.view.width = 60

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
-- NORMAL MODE
lvim.keys.normal_mode["<C-s>"] = ":wa<cr>"
lvim.keys.normal_mode["<leader>k"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<leader>j"] = ":BufferLineCyclePrev<CR>"

lvim.keys.normal_mode["<leader>sl"] = ":NewpaperLight<CR>"
lvim.keys.normal_mode["<leader>sd"] = ":NewpaperDark<CR>"

lvim.keys.normal_mode["<C-p>"] = ":MarkdownPreviewToggle<CR>"

lvim.keys.normal_mode["<leader><space>"] = "<cmd>lua require('telescope.builtin').resume()<CR>"

-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
lvim.keys.normal_mode["<space>q"] = ":qa!<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- INSERT MODE
lvim.keys.insert_mode["kj"] = "<Esc>"



-- VISUAL MODE

local tb = require('telescope.builtin')

lvim.keys.visual_mode["<leader>st"] = function()
  local text = vim.getVisualSelection()
  tb.current_buffer_fuzzy_find({ default_text = text })
end
lvim.keys.visual_mode["<leader>sT"] = function()
  local text = vim.getVisualSelection()
  tb.live_grep({ default_text = text })
end


function vim.getVisualSelection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end

-- Additional Plugins
-- lvim.plugins = {
--     {"folke/tokyonight.nvim"},
--     {
--       "folke/trouble.nvim",
--       cmd = "TroubleToggle",
--     },
-- }
lvim.plugins = {
  {
    "yorik1984/newpaper.nvim",
    config = function()
      require("newpaper").setup({
        style = "light"
      })
      -- put it here
      vim.cmd("colorscheme newpaper")
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && ./install.sh",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 1
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
        -- for example, context is off by default, use this to turn it on
        show_current_context = true,
      }
    end
  },
  { "tpope/vim-surround", keys = { "c", "d", "y" } },
  { "kdheepak/lazygit.nvim" }
}


-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
  },
  -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
  },
}

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
-- }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = false
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = false
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- no need to set style = "lvim"
lvim.builtin.lualine.style = "lvim"
local components = require("lvim.core.lualine.components")
lvim.builtin.lualine.sections.lualine_a = { "mode" }
lvim.builtin.lualine.sections.lualine_y = {
  components.location
}

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- make sure server will always be installed even if the server is in skipped_servers list
lvim.lsp.installer.setup.ensure_installed = {
  "sumeko_lua",
  "jsonls",
}
-- -- change UI setting of `LspInstallInfo`
-- -- see <https://github.com/williamboman/nvim-lsp-installer#default-configuration>
-- lvim.lsp.installer.setup.ui.check_outdated_servers_on_open = false
-- lvim.lsp.installer.setup.ui.border = "rounded"
-- lvim.lsp.installer.setup.ui.keymaps = {
--     uninstall_server = "d",
--     toggle_server_expand = "o",
-- }

-- ---@usage disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black",
    extra_args = { "--line-length", "120" },
    filetypes = { "python" },
  },
  -- { command = "isort", filetypes = { "python" } },
  {
    -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
    command = "prettier",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
    extra_args = { "--print-with", "120" },
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "typescript", "typescriptreact" },
  },
}

-- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  {
    command = "flake8",
    filetypes = { "python" },
    extra_args = { "--config", "~/.config/flake8" }
  },
  -- {
  --   command = "mypy",
  --   filetypes = { "python" },
  -- },
  {
    command = "pylint",
    filetypes = { "python" },
    extra_args = { "--max-line-length", "120" }
  },
  {
    command = "markdownlint",
    filetypes = { "markdown" },
    extra_args = { "--disable", "MD013" },
  },
  {
    -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
    command = "shellcheck",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
    extra_args = { "--severity", "warning" },
  },
  {
    command = "codespell",
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "javascript", "python" },
  }
}

-- -- set a code actions
-- local code_actions = require "lvim.lsp.null-ls.code_actions"
-- code_actions.setup {
--   {
--     command = "proselint"
--   },
-- }


-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- local customGroup = vim.api.nvim_create_augroup("CustomGroup", { clear = true })
-- vim.api.nvim_create_autocmd(
--   {"BufEnter", "BufNew"},
--   {
--     pattern = { "*" },
--     group = customGroup,
--     command = "normal zR",
--   }
-- )
