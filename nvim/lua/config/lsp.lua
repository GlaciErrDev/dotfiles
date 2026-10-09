-- LSP foundation: client capabilities, per-server registration, global
-- config, attach-time keymaps, diagnostics UX.
--
-- This is plain core config (not a plugin hook): servers register from
-- the nvim-lspconfig built-in defaults (their rtp is active as soon as
-- the plugin is installed), and the capabilities/keymaps must exist
-- before any LSP activity. Language-specific plugins (lazydev,
-- rustaceanvim, ...) live in lua/plugins/lang/*.lua.

local augroup = vim.api.nvim_create_augroup("lsp", { clear = true })

local function capabilities()
  -- Prefer blink.cmp's richer capabilities when it is already loaded;
  -- otherwise enable the key fields manually so LSP servers still get
  -- snippet support without forcing an early blink load.
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    return blink.get_lsp_capabilities()
  end
  local caps = vim.lsp.protocol.make_client_capabilities()
  local item = caps.textDocument.completion.completionItem
  item.snippetSupport = true
  item.labelDetailsSupport = true
  item.insertReplaceSupport = true
  item.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits", "insertReplaceEdit" },
  }
  caps.textDocument.completion.insertTextMode = 2
  caps.textDocument.completion.insertTextModeSupport = { valueSupport = 2 }
  return caps
end

vim.lsp.config("*", {
  capabilities = capabilities(),
})

-- Per-server registration. Settings only: command, root markers and
-- workspace defaults come from the nvim-lspconfig built-in configs,
-- which merge with these on enable. Binaries are provisioned by Mason
-- (lua/plugins/formatting.lua), except rust-analyzer, which rustaceanvim
-- owns (system rustup toolchain).
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "standard",
      },
    },
  },
})
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      usePlaceholders = true,
      completeUnimported = true,
      analyses = {
        unusedparams = true,
        unusedwrite = true,
        staticcheck = true,
      },
    },
  },
})
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      -- Whole runtime (plugin runtimes included) as the workspace
      -- library, so config files get full Neovim API coverage.
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        maxPreload = 100000,
      },
      diagnostics = { globals = { "vim" } },
      completion = { callSnippet = "Replace" },
    },
  },
})
vim.lsp.enable({ "pyright", "gopls", "lua_ls" })


vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded" },
  underline = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(ev)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "g0", vim.lsp.buf.type_definition, "Go to type definition")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>ci", function()
      vim.lsp.inlay_hint(nil, nil, { bufnr = ev.buf })
    end, "Toggle inlay hints")
    map("n", "<leader>uh", function()
      vim.lsp.inlay_hint(nil, nil, { bufnr = ev.buf })
    end, "Toggle inlay hints")
    map("n", "<leader>cx", vim.diagnostic.open_float, "Show diagnostic")
    map("n", "<leader>cl", function()
      vim.diagnostic.setloclist({ bufnr = ev.buf })
    end, "Diagnostics to loclist")
    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Next diagnostic")
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Previous diagnostic")
  end,
})
