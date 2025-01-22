return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "famiu/bufdelete.nvim",
  },
  version = "*",
  opts = {
    options = {
      mode = "buffers",
      separator_style = "thin",
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)

    local keymap = vim.keymap
    keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
    keymap.set("n", "]b", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
    keymap.set("n", "<leader>bx", "<cmd>Bdelete<CR>", { desc = "Close current buffer" })
    keymap.set("n", "<leader>ba", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close all other buffers" })
  end,
}
