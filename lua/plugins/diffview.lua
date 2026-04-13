return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      -- PR-style diff (merge-base comparison like GitHub)
      {
        "<leader>gd",
        function()
          vim.cmd("DiffviewOpen main...HEAD")
        end,
        desc = "Diff vs main (PR style)",
      },

      -- Exact tip-to-tip diff
      {
        "<leader>gD",
        function()
          vim.cmd("DiffviewOpen main..HEAD")
        end,
        desc = "Diff vs main (direct)",
      },

      -- Close diffview
      {
        "<leader>gq",
        "<cmd>DiffviewClose<cr>",
        desc = "Close Diffview",
      },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,

      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },

      file_panel = {
        win_config = {
          position = "left",
          width = 35,
        },
      },
    },
  },
}
