-- "хлебные крошки" чтобы увидеть в какой функции / классе находимся
return {
  "SmiteshP/nvim-navic",
  dependencies = "neovim/nvim-lspconfig",
  config = function()
    local navic = require("nvim-navic")
    navic.setup({})
  end,
}
