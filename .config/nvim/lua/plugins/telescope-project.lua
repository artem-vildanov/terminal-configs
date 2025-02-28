return {
  "nvim-telescope/telescope-project.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    vim.api.nvim_set_keymap(
      "n",
      "<C-p>",
      ":lua require'telescope'.extensions.project.project{}<CR>",
      { desc = "Open project picker", noremap = true, silent = true }
    )
  end,
}
