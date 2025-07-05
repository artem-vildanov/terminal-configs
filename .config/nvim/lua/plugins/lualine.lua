-- Получить корень проекта: от LSP или fallback на текущую папку
local function get_project_root()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.config.root_dir then
      return client.config.root_dir
    end
  end
  return vim.loop.cwd()
end

-- Относительный путь от корня
local function get_relative_path()
  local filepath = vim.api.nvim_buf_get_name(0)
  local root = get_project_root()

  -- fallback: если пусто
  if filepath == "" then
    return "[No Name]"
  end

  -- если файл не в проекте — вернуть имя файла
  if not filepath:find(root, 1, true) then
    return vim.fn.fnamemodify(filepath, ":t")
  end

  -- относительный путь от корня
  local relpath = filepath:sub(#root + 2)
  return relpath
end

local function navic_fn()
  local n = require('nvim-navic')
  return function()
    return n.get_location()
  end
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    lualine.setup({
      sections = {
        -- lualine_x = {
        --   {
        --     require("noice").api.statusline.mode.get,
        --     cond = require("noice").api.statusline.mode.has,
        --     color = { fg = "#ff9e64" },
        --   },
        -- },
        lualine_c = { get_relative_path },
        lualine_x = { navic_fn() },
      },
      options = {
        -- theme = "gruvbox-material",
        -- theme = "onedark",
        theme = "catppuccin",
      },
    })
  end,
}
