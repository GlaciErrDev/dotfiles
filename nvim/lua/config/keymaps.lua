-- Global keymaps: the LazyVim starter defaults (lua/lazyvim/config/keymaps.lua)
-- plus personal keymaps from the old config, ported over as-is.
-- Plugin-scoped maps (LSP, gitsigns, fzf-lua, oil, ...) live in their specs.
-- <C-h/j/k/l> are plain window movement (LazyVim default); window-picker

local map = vim.keymap.set

-- Better up/down (respect virtual lines unless a count is given).
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down" })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up" })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up" })

-- Move to window using the <ctrl> hjkl keys.
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Resize window using <ctrl> or <alt> arrow keys.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })
map("n", "<A-Up>", "<cmd>resize +2<CR>", { desc = "Increase Window Height" })
map("n", "<A-Down>", "<cmd>resize -2<CR>", { desc = "Decrease Window Height" })
map("n", "<A-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map("n", "<A-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- Move lines.
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<CR>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<CR>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<CR>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", { desc = "Move Up" })
map("v", "J", "<cmd>m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", "<cmd>m '-2<CR>gv=gv", { desc = "Move line up" })

-- Buffers.
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<CR>", { desc = "Switch to Other Buffer" })

local function bufdelete(buf)
  if vim.bo[buf].modified
    and vim.fn.confirm("Buffer is modified. Discard changes?", { "&Yes", "&No" }) ~= 1 then
    return
  end
  vim.api.nvim_buf_delete(buf, { force = true })
end

map("n", "<leader>bd", function()
  bufdelete(vim.api.nvim_get_current_buf())
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= cur then
      bufdelete(b)
    end
  end
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bi", function()
  local visible = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible[vim.api.nvim_win_get_buf(win)] = true
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if not visible[b] then
      bufdelete(b)
    end
  end
end, { desc = "Delete Invisible Buffers" })
map("n", "<leader>bD", function()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  bufdelete(buf)
  if #vim.api.nvim_list_wins() > 1 then
    vim.api.nvim_win_close(win, true)
  end
end, { desc = "Delete Buffer and Window" })

-- Clear search highlight and hide completion on escape.
map(
  { "i", "n", "s" },
  "<esc>",
  function()
    pcall(function()
      require("blink.cmp").hide()
    end)
    vim.cmd("noh")
    return "<esc>"
  end,
  { expr = true, desc = "Escape and Clear hlsearch" }
)

-- Clear search, diff update and redraw.
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- Center the screen after search jumps (personal).
map("n", "n", "nzzzv", { desc = "Next Search Result" })
map("n", "N", "NzzzV", { desc = "Prev Search Result" })

-- Add undo break-points.
map("i", ",", ",<c-g>u", { desc = "Undo break" })
map("i", ".", ".<c-g>u", { desc = "Undo break" })
map("i", ";", ";<c-g>u", { desc = "Undo break" })

-- Save / quit.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map({ "i", "x", "s" }, "<C-s>", "<cmd>w<CR><esc>", { desc = "Save File" })
map("n", "<C-s>", "<cmd>wa<CR>", { desc = "Save all buffers" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit All" })

-- Help for the word under the cursor (LazyVim uses plain :help).
map("n", "<leader>h", function()
  local word = vim.fn.expand("<cword>")
  vim.cmd("help " .. word)
end, { desc = "Help for word" })

-- keywordprg.
map("n", "<leader>K", "<cmd>norm! K<CR>", { desc = "Keywordprg" })

-- Better indenting (keep the selection).
map("x", "<", "<gv", { desc = "Indent Left" })
map("x", ">", ">gv", { desc = "Indent Right" })

-- Commenting (gcc is mini.comment).
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<CR>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<CR>fxa<bs>", { desc = "Add Comment Above" })

-- Plugins.
map("n", "<leader>l", "<cmd>Lazy<CR>", { desc = "Lazy" })

-- New file.
map("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New File" })

-- Location list / quickfix list.
map("n", "<leader>xl", function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
    vim.cmd("lclose")
  else
    vim.cmd("lopen")
  end
end, { desc = "Location List" })
map("n", "<leader>xq", function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end, { desc = "Quickfix List" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- Diagnostics by severity (]d/[d and <leader>cx live in the LSP attach hook).
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
local function diagnostic_goto(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- Toggle options.
local function toggle_bool(opt)
  return function()
    vim.opt[opt] = not vim.opt[opt]
  end
end
map("n", "<leader>us", toggle_bool("spell"), { desc = "Toggle Spelling" })
map("n", "<leader>uw", toggle_bool("wrap"), { desc = "Toggle Wrap" })
map("n", "<leader>uL", toggle_bool("relativenumber"), { desc = "Toggle Relative Number" })
map("n", "<leader>ul", toggle_bool("number"), { desc = "Toggle Line Number" })
map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle Diagnostics" })
map("n", "<leader>uc", function()
  vim.o.conceallevel = vim.o.conceallevel > 0 and 0 or 2
end, { desc = "Toggle Conceal Level" })
map("n", "<leader>uA", function()
  vim.o.showtabline = vim.o.showtabline > 0 and 0 or 2
end, { desc = "Toggle Tabline" })
map("n", "<leader>uT", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf]._ts_on then
    vim.b[buf]._ts_on = nil
    vim.treesitter.stop(buf)
  else
    vim.b[buf]._ts_on = true
    vim.treesitter.start(buf)
  end
end, { desc = "Toggle Treesitter" })
map("n", "<leader>ub", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
end, { desc = "Toggle Dark Background" })
-- Git (fzf-lua git pickers trigger from plugins/navigation.lua).
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function()
    local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
    if root and root ~= "" then
      vim.cmd("botright vsplit | terminal lazygit -w " .. vim.fn.fnameescape(root))
    end
  end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", "<cmd>botright vsplit | terminal lazygit<CR>", { desc = "Lazygit (cwd)" })
end

-- Inspect.
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })
-- Floating terminal (LazyVim: <leader>fT = terminal in cwd, <c-/> to focus).
local function find_term_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
      return win
    end
  end
end

local function focus_terminal()
  local win = find_term_win()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.notify("No terminal window open", vim.log.levels.INFO)
  end
end

local function open_terminal()
  local win = find_term_win()
  if win then
    vim.api.nvim_set_current_win(win)
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  win = vim.api.nvim_open_win(buf, true, { relative = "editor" })
  vim.api.nvim_win_set_config(win, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    row = math.floor(vim.o.lines * 0.1),
    col = math.floor(vim.o.columns * 0.1),
    style = "minimal",
    border = "rounded",
  })
  vim.api.nvim_open_term(buf, { cwd = vim.fn.getcwd() })
  vim.api.nvim_set_current_win(win)
  vim.cmd("startinsert")
end
map("n", "<leader>fT", open_terminal, { desc = "Floating Terminal (cwd)" })
map({ "n", "t" }, "<c-/>", focus_terminal, { desc = "Focus Terminal" })
map({ "n", "t" }, "<c-_>", focus_terminal, { desc = "which_key_ignore" })

-- Windows.
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below" })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window" })
local zoom_win
local function toggle_zoom()
  if zoom_win then
    vim.api.nvim_set_current_win(zoom_win)
    zoom_win = nil
  else
    zoom_win = vim.api.nvim_get_current_win()
    vim.cmd("only")
  end
end
map("n", "<leader>wm", toggle_zoom, { desc = "Toggle Zoom" })
map("n", "<leader>uZ", toggle_zoom, { desc = "Toggle Zoom" })
map("n", "<leader>uz", function()
  vim.cmd("ZenMode")
end, { desc = "Toggle Zen Mode" })

-- Tabs.
map("n", "<leader><Tab>l", "<cmd>tablast<CR>", { desc = "Last Tab" })
map("n", "<leader><Tab>o", "<cmd>tabonly<CR>", { desc = "Close Other Tabs" })
map("n", "<leader><Tab>f", "<cmd>tabfirst<CR>", { desc = "First Tab" })
map("n", "<leader><Tab><Tab>", "<cmd>tabnew<CR>", { desc = "New Tab" })
map("n", "<leader><Tab>]", "<cmd>tabnext<CR>", { desc = "Next Tab" })
map("n", "<leader><Tab>d", "<cmd>tabclose<CR>", { desc = "Close Tab" })
map("n", "<leader><Tab>[", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })

-- Personal keymaps (ported from the LazyVim-era config).
map("i", "kj", "<Esc>", { desc = "Exit INSERT mode" })
map("n", "<C-o>", "<C-o>zz")
map("n", "<C-i>", "<C-i>zz")
map("n", "<C-r>", "<C-r>zz")
map("n", "u", "uzz", { desc = "Undo (centered)" })
map("n", "J", "mzJ`z", { desc = "Join Line (keep cursor)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up (centered)" })
map("x", "p", '"_dP', { desc = "Paste without overwriting register" })
map("n", "<leader>xx", "<cmd>!chmod +x %<CR>", { desc = "Chmod +x", silent = true })
