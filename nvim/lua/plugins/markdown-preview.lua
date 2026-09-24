return {
  {
    "iamcco/markdown-preview.nvim",
    init = function()
      vim.g.mkdp_preview_options = {
        sequence_diagrams = {
          theme = "simple",
        },
      }
    end,
  },
}
