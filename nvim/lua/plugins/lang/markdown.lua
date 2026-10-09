-- Markdown: browser preview via markdown-preview.nvim.
return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
    build = function()
      vim.fn["markdown_preview#util#init"]()
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Preview markdown" },
    },
  },
}
