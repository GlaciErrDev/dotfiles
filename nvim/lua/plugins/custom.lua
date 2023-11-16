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
    main = "ibl",
    opts = {
      indent = {
        char = "▏",
        tab_char = "▏",
        -- char = "▎",
        -- tab_char = "▎",
      },
      scope = {
        enabled = true,
        -- char = "▎",
        char = "▍",
        show_start = false,
      },
      whitespace = {
        remove_blankline_trail = true,
      },
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
        "go",
        "gomod",
        "gowork",
        "gosum",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
  },

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
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

  {
    "neovim/nvim-lspconfig",
    opts = {
      format = {
        timeout_ms = 5000,
      },
      servers = {
        pyright = {},
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
      },
      setup = {
        gopls = function(_, opts)
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "gopls" then
              if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end
          end)
          -- end workaround
        end,
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        go = {
          "goimports",
          "gofumpt",
          "gofmt",
        },
        python = {
          "black",
        },
      },
    },
  },

  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      if type(opts.sources) == "table" then
        local nls = require("null-ls")
        vim.list_extend(opts.sources, {
          nls.builtins.code_actions.gomodifytags,
          nls.builtins.code_actions.impl,
          nls.builtins.code_actions.refactoring,
          nls.builtins.diagnostics.flake8.with({
            extra_args = { "--config", "~/.config/flake8" },
          }),
          nls.builtins.diagnostics.mypy,
          nls.builtins.diagnostics.shellcheck,
          nls.builtins.formatting.shfmt.with({
            extra_args = { "-i", "2", "-ci" },
          }),
          nls.builtins.formatting.black,
          nls.builtins.formatting.gofumpt,
          nls.builtins.formatting.goimports_reviser,
        })
      end
    end,
  },
}
