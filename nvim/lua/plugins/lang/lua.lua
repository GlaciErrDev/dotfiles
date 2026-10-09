-- Lua: lazydev for Neovim API completions/diagnostics.
-- (lua_ls registration lives in lua/config/lsp.lua; stylua formatting in
-- conform.nvim, see plugins/formatting.lua.)
return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    config = function(_, opts)
      require("lazydev").setup(opts)
    end,
    opts = {
      library = {
        { path = "${3rd}/luassert", words = { "^luassert%." } },
        { path = "3rdparty", words = { "%u%.%u.*" } },
      },
    },
  },
}
