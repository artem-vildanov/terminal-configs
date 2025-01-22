-- return {
--   "ellisonleao/gruvbox.nvim",
--   priority = 1000,
--   config = function()
--     vim.cmd("colorscheme gruvbox")
--   end
-- }

-- return {
-- 	"olimorris/onedarkpro.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		vim.cmd("colorscheme onedark")
-- 	end,
-- }

return {
  "catppuccin/nvim",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato",
      custom_highlights = function(colors)
        return {
          -- Пример выделения для Go пакетов
          ["@namespace"] = {
            -- fg = colors.blue,
            style = { "italic" }, -- Стиль текста
          },
          Comment = {
            fg = colors.overlay1, -- Цвет комментариев
            style = { "italic" },
          },
        }
      end,
    })
    vim.cmd("colorscheme catppuccin")
  end,
}
