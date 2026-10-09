-- Snacks: the UI layer for pickers, explorer, terminal, scratch buffers,
-- word references and notifications.
--
-- All animations are disabled: vim.g.snacks_animate is snacks' global
-- animation gate (Snacks.animate.enabled() checks it first), the scroll
-- module (smooth scrolling) is explicitly off, and no other animated
-- module is enabled.

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
      -- noice.nvim owns vim.notify until the commit that removes it.
      notifier = { enabled = false },
    },
  },
}
