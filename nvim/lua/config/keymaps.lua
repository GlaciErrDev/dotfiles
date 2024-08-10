-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- INSERT --
map("i", "kj", "<Esc>", { desc = "Exit INSERT mode" })

-- NORMAL --
map("n", "<C-s>", "<cmd>wa<CR>", { desc = "Save all buffers" })
map("n", "<C-o>", "<C-o>zz")
map("n", "<C-i>", "<C-i>zz")
map("n", "<C-r>", "<C-r>zz")
map("n", "u", "uzz")
map("n", "n", "nzzzv")
map("n", "N", "NzzzV")
map("n", "<leader>r", "<cmd>lua require('telescope.builtin').resume()<CR>", { desc = "Previouse Telescope command" })

map({ "n", "v" }, "<leader>]", ":Gen<CR>")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d›", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Preserve copy selection after pasting it
map("x", "p", '"_dP')

map("n", "<leader>xx", "<cmd>!chmod +x %<CR>", { silent = true })
