return {
  "NStefan002/screenkey.nvim",
  lazy = false,
  version = "*", -- or branch = "main", to use the latest commit
  config = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("AutostartScreenkey", {}),
      command = "Screenkey toggle",
      desc = "Autostart Screenkey on VimEnter",
    })
  end,
}
