-- Snacks: the single UI layer for pickers, explorer, terminal, scratch
-- buffers and notifications. Replaces fzf-lua, oil.nvim, noice.nvim,
-- focus.nvim and vim-illuminate (Snacks.words).
--
-- All animations are disabled: vim.g.snacks_animate is snacks' global
-- animation gate (Snacks.animate.enabled() checks it first), the scroll
-- module (smooth scrolling) is explicitly off, and no other animated
-- module is enabled.
local function root()
  return vim.fs.root(0, { ".git", "stylua.toml", ".luarc.json", "pyproject.toml", "go.mod" })
      or vim.fn.getcwd()
end

return {
  {
    "folke/snacks.nvim",
    -- Eager: the notifier hook and picker/terminal handlers must be live
    -- before the user's first keypress.
    lazy = false,
    priority = 900,
    config = function(_, opts)
      -- Global kill switch for every animated feature in snacks.
      vim.g.snacks_animate = false
      require("snacks").setup(opts)
    end,
    opts = {
      -- No animations anywhere: the global gate (vim.g.snacks_animate) is
      -- set in config, and the only animated module (scroll) is off.
      animate = { enabled = false },
      scroll = { enabled = false },
      picker = { enabled = true },
      explorer = { enabled = true },
      terminal = { enabled = true },
      scratch = { enabled = true },
      words = { enabled = true },
      notifier = { enabled = true },
    },
    -- stylua: ignore
    keys = {
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep({ cwd = root() }) end, desc = "Grep (Root Dir)" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader><space>", function() Snacks.picker.files({ cwd = root() }) end, desc = "Find Files (Root Dir)" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>.", function() Snacks.scratch.open() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      -- find
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files({ cwd = root() }) end, desc = "Find Files (Root Dir)" },
      { "<leader>fF", function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end, desc = "Find Files (cwd)" },
      -- personal: <leader>fg is the ripgrep-backed live grep (snacks' grep
      -- source uses rg); the CSV's git-files entry has no binding.
      { "<leader>fg", function() Snacks.picker.grep({ cwd = root() }) end, desc = "Live Grep (rg)" },
      -- personal: LSP references (the CSV's "Recent" entry has no binding).
      { "<leader>fr", function() Snacks.picker.lsp_references() end, desc = "LSP References" },
      { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Recent (cwd)" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      -- git (personal git-log trio, re-homed from fzf-lua)
      { "<leader>gL", function() Snacks.picker.git_log({ cwd = vim.fn.getcwd() }) end, desc = "Git Log (cwd)" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Current File History" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
      { "<leader>gD", function() Snacks.picker.git_diff({ base = "origin", group = true }) end, desc = "Git Diff (origin)" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
      { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
      { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
      { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
      -- grep
      { "<leader>sg", function() Snacks.picker.grep({ cwd = root() }) end, desc = "Grep (Root Dir)" },
      { "<leader>sG", function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end, desc = "Grep (cwd)" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, mode = { "n", "x" }, desc = "Grep Word (Root Dir)" },
      { "<leader>sW", function() Snacks.picker.grep_word({ filter = { cwd = true } }) end, mode = { "n", "x" }, desc = "Grep Word (cwd)" },
      -- search
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },
      -- ui
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      -- explorer (personal `-` file-manager binding kept, oil replaced)
      { "-", function() Snacks.explorer({ cwd = vim.fn.getcwd() }) end, mode = "n", desc = "Explorer (cwd)" },
      { "<leader>e", function() Snacks.explorer({ cwd = root() }) end, desc = "Explorer (Root Dir)" },
      { "<leader>E", function() Snacks.explorer({ cwd = vim.fn.getcwd() }) end, desc = "Explorer (cwd)" },
      { "<leader>fe", function() Snacks.explorer({ cwd = root() }) end, desc = "Explorer (Root Dir)" },
      { "<leader>fE", function() Snacks.explorer({ cwd = vim.fn.getcwd() }) end, desc = "Explorer (cwd)" },
      -- terminal
      { "<leader>fT", function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, desc = "Terminal (cwd)" },
      { "<leader>ft", function() Snacks.terminal(nil, { cwd = root() }) end, desc = "Terminal (Root Dir)" },
      { "<c-/>", function() Snacks.terminal(nil, { cwd = root() }) end, mode = { "n", "t" }, desc = "Terminal (Root Dir)" },
      { "<c-_>", function() Snacks.terminal(nil, { cwd = root() }) end, mode = { "n", "t" }, desc = "which_key_ignore" },
    },
  },
}
