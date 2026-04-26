return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate Left (tmux)" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate Down (tmux)" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate Up (tmux)" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate Right (tmux)" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate Previous (tmux)" },
    },
  },
}
