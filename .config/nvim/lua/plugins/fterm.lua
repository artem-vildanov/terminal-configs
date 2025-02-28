return {
  "numToStr/FTerm.nvim",
  config = function()
    vim.keymap.set("n", "<C-t>", '<CMD>lua require("FTerm").toggle()<CR>')
    vim.keymap.set(
      "t",
      "<C-t>",
      '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>'
    )
  end,
}
