require("nvim-tree").setup({
    view = {
        width = 60
    }
})

vim.keymap.set('n', '<leader>e', ':NvimTreeFindFileToggle<CR>')
