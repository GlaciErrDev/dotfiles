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
    map("n", "gd", vim.lsp.buf.definition, "Goto definition")
    map("n", "gr", Snacks.picker.lsp_references, "References")
    map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
    map("n", "gy", vim.lsp.buf.type_definition, "Goto type definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature help")
    map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature help")
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
    map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & display Codelens")
    map("n", "<leader>cR", function()
      Snacks.rename.rename_file()
    end, "Rename file")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "x" }, "<leader>cA", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "source" }, diagnostics = {} },
      })
    end, "Source action")
    map("n", "<leader>co", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "source.organizeImports" }, diagnostics = {} },
      })
    end, "Organize imports")
    map("n", "<leader>ss", function()
      Snacks.picker.lsp_symbols()
    end, "LSP symbols")
    map("n", "<leader>sS", function()
      Snacks.picker.lsp_workspace_symbols()
    end, "LSP workspace symbols")
    map("n", "gai", function()
      Snacks.picker.lsp_incoming_calls()
    end, "Calls incoming")
    map("n", "gao", function()
      Snacks.picker.lsp_outgoing_calls()
    end, "Calls outgoing")
    -- Reference navigation: snacks.words (vim-illuminate replaced).
    map("n", "]]", function()
      Snacks.words.jump(vim.v.count1)
    end, "Next reference")
    map("n", "[[", function()
      Snacks.words.jump(-vim.v.count1)
    end, "Previous reference")
    map("n", "<a-n>", function()
      Snacks.words.jump(vim.v.count1, true)
    end, "Next reference")
    map("n", "<a-p>", function()
      Snacks.words.jump(-vim.v.count1, true)
    end, "Previous reference")
    map("n", "<leader>ci", function()
      vim.lsp.inlay_hint(nil, nil, { bufnr = ev.buf })
    end, "Toggle inlay hints")
    map("n", "<leader>uh", function()
      vim.lsp.inlay_hint(nil, nil, { bufnr = ev.buf })
    end, "Toggle inlay hints")
    map("n", "<leader>cx", vim.diagnostic.open_float, "Show diagnostic")
    map("n", "<leader>cl", function()
      Snacks.picker.lsp_config()
    end, "Lsp info")
    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Next diagnostic")
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Previous diagnostic")
  end,
})
