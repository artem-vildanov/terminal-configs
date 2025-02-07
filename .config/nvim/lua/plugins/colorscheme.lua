-- return {
--   "catppuccin/nvim",
--   priority = 1000,
--   config = function()
--     require("catppuccin").setup({
--       flavour = "frappe",
--       custom_highlights = function(colors)
--         return {
--           -- Пример выделения для Go пакетов
--           ["@namespace"] = {
--             -- fg = colors.blue,
--             style = { "italic" }, -- Стиль текста
--           },
--           Comment = {
--             fg = colors.overlay1, -- Цвет комментариев
--             style = { "italic" },
--           },
--         }
--       end,
--     })
--     vim.cmd("colorscheme catppuccin")
--   end,
-- }

-- return {
--   "rebelot/kanagawa.nvim",
--   priority = 1000,
--   config = function()
--     vim.cmd("colorscheme kanagawa")
--
--     require("kanagawa").setup({
--       compile = false, -- enable compiling the colorscheme
--       undercurl = true, -- enable undercurls
--       commentStyle = { italic = true },
--       functionStyle = {},
--       keywordStyle = { italic = true },
--       statementStyle = { bold = true },
--       typeStyle = {},
--       transparent = false, -- do not set background color
--       dimInactive = false, -- dim inactive window `:h hl-NormalNC`
--       terminalColors = true, -- define vim.g.terminal_color_{0,17}
--       colors = { -- add/modify theme and palette colors
--         palette = {},
--         theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
--       },
--       overrides = function(colors) -- add/modify highlights
--         return {}
--       end,
--       theme = "wave", -- Load "wave" theme when 'background' option is not set
--       background = { -- map the value of 'background' option to a theme
--         dark = "wave", -- try "dragon" !
--         light = "lotus",
--       },
--     })
--   end,
-- }

-- return {
--   "zenbones-theme/zenbones.nvim",
--   dependencies = "rktjmp/lush.nvim",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     -- vim.cmd.colorscheme('zenbones')
--     -- vim.cmd.colorscheme("seoulbones")
--     vim.cmd.colorscheme('zenburned')
--   end,
-- }

return {
  "sainnhe/gruvbox-material",
  priority = 1000,
  config = function()
    vim.g.gruvbox_material_enable_italic = true
    vim.cmd.colorscheme("gruvbox-material")
  end,
}
