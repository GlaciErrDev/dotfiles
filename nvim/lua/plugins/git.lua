-- gitsigns hunk maps are buffer-local (on_attach); the gitbrowse pair is
-- global (triggered here for lazy loading).
local function gitbrowse(copy)
  local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    vim.notify("Not a git repository", vim.log.levels.ERROR)
    return
  end
  local url = vim.fn.systemlist({ "git", "remote", "get-url", "origin" })[1]
  if vim.v.shell_error ~= 0 or not url or url == "" then
    vim.notify("No origin remote", vim.log.levels.ERROR)
    return
  end
  url = url
    :gsub("^git@github.com:", "https://github.com/")
    :gsub("^gitlab@gitlab.com:", "https://gitlab.com/")
    :gsub("%.git$", "")
  local rel = vim.fn.expand("%:p"):sub(#root + 2)
  local link = url .. "/" .. rel .. "#" .. vim.fn.line(".")
  if copy then
    vim.fn.setreg("+", link)
    vim.notify("URL copied: " .. link, vim.log.levels.INFO)
  else
    vim.fn.open(link)
  end
end

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "VeryLazy" },
    keys = {
      { "<leader>gB", function()
        gitbrowse(false)
      end, mode = { "n", "v" }, desc = "Git Browse (open)" },
      { "<leader>gY", function()
        gitbrowse(true)
      end, mode = { "n", "v" }, desc = "Git Browse (copy)" },
    },
    config = function()
      local gs = require("gitsigns")
      gs.setup({
        on_attach = function(bufnr)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "GitSigns: " .. desc })
          end
          map("n", "]h", function()
            gs.next_hunk()
          end, "Next hunk")
          map("n", "[h", function()
            gs.prev_hunk()
          end, "Previous hunk")
          map("n", "<leader>gh", function()
            gs.preview_hunk()
          end, "Preview hunk")
          map("n", "<leader>gs", function()
            gs.stage_hunk()
          end, "Stage hunk")
          map("n", "<leader>gx", function()
            gs.reset_hunk()
          end, "Reset hunk")
          map("n", "<leader>gb", function()
            gs.blame_line({ full = true })
          end, "Blame line")
          map("v", "<leader>gs", function()
            gs.stage_hunk()
          end, "Stage hunk")
          map("v", "<leader>gx", function()
            gs.reset_hunk()
          end, "Reset hunk")
        end,
      })
    end,
  },
}
