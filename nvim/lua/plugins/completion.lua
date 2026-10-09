return {
  {
    "saghen/blink.cmp",
    -- v2 requires a native "blink.lib" module (Rust build) that is not
    -- installed; pin the latest v1 release, which has no native deps and
    -- matches the luasnip snippet expansion below.
    version = "v1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      keymap = { preset = "default" },
      signature = { enabled = true },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    build = "make -s -j2",
    dependencies = { "nvim-lua/plenary.nvim", "rafamadriz/friendly-snippets" },
    event = "InsertEnter",
    config = function()
      -- Load the community snippets (friendly-snippets, a dependency, so its
      -- package.json is on rtp here). Done in config rather than on a User
      -- VeryLazy autocmd: that event fires at startup, before InsertEnter
      -- loads LuaSnip, so the autocmd would never trigger.
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
