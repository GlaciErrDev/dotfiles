return {
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
