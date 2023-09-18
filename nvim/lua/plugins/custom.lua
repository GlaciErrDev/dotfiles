return {
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		event = "VeryLazy",
		version = "2.*",
		config = function()
			require("window-picker").setup()
		end,
	},
	{
		"yorik1984/newpaper.nvim",
		opts = {
			style = "light",
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "newpaper",
		},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		opts = {
			char = "▎",
			show_current_context = true,
		},
	},
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

	-- add more treesitter parsers
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			--https://github.com/LunarVim/LunarVim/issues/4305#issuecomment-1681451926
			ignore_install = { "dart" },
			ensure_installed = {
				"bash",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"rust",
				"query",
				"regex",
				"tsx",
				"typescript",
				"vim",
				"yaml",
			},
		},
	},

	-- use mini.starter instead of alpha
	{ import = "lazyvim.plugins.extras.ui.mini-starter" },

	-- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
	{ import = "lazyvim.plugins.extras.lang.json" },

	-- add any tools you want to have installed below
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"stylua",
				"shellcheck",
				"shfmt",
				"flake8",
			},
		},
	},
}
