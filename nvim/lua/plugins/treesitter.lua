return {
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = { "TSUpdate", "TSUpdateSync", "TSInstall", "TSInstallSync", "TSUninstall" },
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = true,
    opts = {
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "python",
        "go",
        "rust",
        "markdown",
        "markdown_inline",
        "json",
        "yaml",
        "toml",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      fold = { enable = true },
    },
  },
  {
    -- Ships the per-language textobjects.scm queries (used by mini.ai's
    -- treesitter objects). Its current API has no auto keymaps; the move
    -- keymaps are attached per buffer below.
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "VeryLazy" },
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        -- Buffer-local move keymaps (LazyVim layout).
        keys = {
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)

      -- Buffer-local move keymaps for filetypes that have textobjects
      -- queries (port of LazyVim's treesitter textobjects attach).
      local function attach(buf)
        local ft = vim.bo[buf].filetype
        local move = opts.move or {}
        if not (move.enable and #vim.treesitter.query.get_files(ft, "textobjects") > 0) then
          return
        end
        for method, keymaps in pairs(move.keys or {}) do
          for key, query in pairs(keymaps) do
            local queries = type(query) == "table" and query or { query }
            local parts = {}
            for _, q in ipairs(queries) do
              local part = q:gsub("@", ""):gsub("%..*", "")
              part = part:sub(1, 1):upper() .. part:sub(2)
              parts[#parts + 1] = part
            end
            local desc = table.concat(parts, " or ")
            desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
            vim.keymap.set({ "n", "x", "o" }, key, function()
              if vim.wo.diff and key:find("[cC]") then
                return vim.cmd("normal! " .. key)
              end
              require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
            end, { buffer = buf, desc = desc, silent = true })
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ts_textobjects", { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        attach(buf)
      end
    end,
  },
}
