-- Core autocmds (plugin-managed ones live in their spec files).

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("core", { clear = true })

-- Keep windows in sync with the editor size.
autocmd("VimResized", {
  group = "core",
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- Highlight the text just yanked.
autocmd("TextYankPost", {
  group = "core",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Re-center the window when starting to type in the middle of a long file.
autocmd("TextChangedI", {
  group = "core",
  callback = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local total = vim.api.nvim_buf_line_count(0)
    local height = vim.api.nvim_win_get_height(0)
    if cursor[1] > total - height * 0.25 and cursor[1] < total - height * 0.75 then
      vim.cmd("normal! z.")
    end
  end,
})

-- Close help buffers with `q`.
autocmd("FileType", {
  group = "core",
  pattern = "help",
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close help" })
  end,
})

-- Terminal buffers: <Esc><Esc> back to normal, <C-w> to window commands.
autocmd("FileType", {
  group = "core",
  pattern = "terminal",
  callback = function()
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = true, desc = "Exit terminal mode" })
    vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { buffer = true, desc = "Terminal: window command" })
  end,
})

-- No line numbers in UI-ish buffers.
autocmd("FileType", {
  group = "core",
  pattern = { "diff", "qf" },
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
  end,
})
