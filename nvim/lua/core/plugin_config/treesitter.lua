require("nvim-treesitter.configs").setup({
    -- A list of parser names, or all
    ensure_installed = {
        "markdown", 
        "lua", 
        "yaml", 
        "sql", 
        "make",
        "json",
        "gitignore",
        "dockerfile",
        "rust", 
        "python", 
        "bash"
    },

    -- Install parsers syncronously (only applied to `ensure_installed`)
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
    },
})
