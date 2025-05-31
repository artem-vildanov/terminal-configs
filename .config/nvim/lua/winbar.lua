local M = {}

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

function M.get_winbar()
  return get_relative_path()
end

return M
