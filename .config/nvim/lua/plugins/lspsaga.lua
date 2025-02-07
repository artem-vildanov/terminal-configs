return {
  "nvimdev/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- optional
    "nvim-tree/nvim-web-devicons", -- optional
  },
  config = function()
    require("lspsaga").setup({
      lightbulb = {
        enable = false,
      },
      hover = {
        max_width = 0.6,
        max_height = 0.6,
      },
    })
    vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "show hover" })
  end,
}
