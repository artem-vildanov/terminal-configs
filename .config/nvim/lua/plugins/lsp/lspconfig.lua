local MAX_HOVER_WIDTH_SYMBOLS = 50
local MAX_HOVER_HEIGHT_SYMBOLS = 15

local function replaceAt(str, startIdx, endIdx, replacement)
  return str:sub(1, startIdx - 1) .. replacement .. str:sub(endIdx + 1)
end

local function format_code_in_parentheses(lines)
  -- vim.notify(table.concat(lines, "|"), vim.log.levels.INFO)

  local isInsideCodeBlock = false
  for codeIndex = 1, #lines, 1 do
    local codeFragment = lines[codeIndex]

    local function indentCode()
      codeFragment = codeFragment:gsub("\n", "\n  "):gsub("^%s+", "  ")
    end

    -- найти подстроки внутри круглых скоб, начиная с позиции searchStart,
    -- при этом подстроки должны содержать хотя бы одну запятую
    local function searchWithComma(searchStart)
      local pos = searchStart or 1 -- Начальная позиция поиска

      while true do
        -- Найти следующую подстроку в круглых скобках
        local oldSubstringStart, oldSubstringEnd =
          codeFragment:find("%b()", pos)

        -- Если ничего не нашли — вернуть nil
        if not oldSubstringStart then
          return nil, nil
        end

        -- Внутреннее содержимое скобок
        local inside =
          codeFragment:sub(oldSubstringStart + 1, oldSubstringEnd - 1)

        -- Если внутри есть запятая, вернуть найденную подстроку
        if inside:find(",", 1, true) then
          return oldSubstringStart, oldSubstringEnd
        end

        -- если внутри не было запятой, то продолжаем поиск
        -- после текущей найденной подстроки
        pos = oldSubstringEnd + 1
      end
    end

    -- найти подстроки внутри круглых скоб, начиная с позиции searchStart,
    -- при этом подстроки не должны содержать запятой
    local function searchWithoutComma(searchStart)
      local pos = searchStart or 1 -- Начальная позиция поиска

      while true do
        -- Найти следующую подстроку в круглых скобках
        local oldSubstringStart, oldSubstringEnd =
          codeFragment:find("%b()", pos)

        -- Если ничего не нашли — вернуть nil
        if not oldSubstringStart then
          return nil, nil
        end

        -- Внутреннее содержимое скобок
        local inside =
          codeFragment:sub(oldSubstringStart + 1, oldSubstringEnd - 1)

        -- Если нет запятых, вернуть найденную подстроку
        if not inside:find(",", 1, true) then
          return oldSubstringStart, oldSubstringEnd
        end

        -- Продолжить поиск после текущей найденной подстроки
        pos = oldSubstringEnd + 1
      end
    end

    local function format(getSubstringStartEnd)
      -- индекс символа, с которого начинать поиск
      -- подстроки заключенной в круглых скобках
      local searchStart = 1

      while true do
        -- Находим подстроку
        local oldSubstringStart, oldSubstringEnd =
          getSubstringStartEnd(searchStart)

        -- Если ничего не найдено — выходим из цикла
        if not oldSubstringStart then
          return true
        end

        -- Извлекаем подстроку
        local oldSubstring =
          codeFragment:sub(oldSubstringStart, oldSubstringEnd)

        -- Форматируем подстроку
        local newSubstring = oldSubstring
          :gsub("%(", "(\n  ")
          :gsub(",%s*", ",\n  ")
          :gsub("%)", "\n)")

        -- Подставляем форматированную подстроку
        codeFragment = replaceAt(
          codeFragment,
          oldSubstringStart,
          oldSubstringEnd,
          newSubstring
        )

        -- Пересчитываем границы новой подстроки
        local newSubstringEnd = oldSubstringStart + #newSubstring - 1

        -- Длина оставшейся части строки
        local unformattedCodeFragmentLength = #codeFragment - newSubstringEnd

        -- Проверяем условие выхода
        if unformattedCodeFragmentLength < MAX_HOVER_WIDTH_SYMBOLS then
          return false
        end

        -- Сдвигаем `searchStart`, чтобы избежать зацикливания
        searchStart = newSubstringEnd + 1
      end
    end

    if codeFragment == "```go" then
      isInsideCodeBlock = true
      goto continue
    end

    if codeFragment == "```" then
      isInsideCodeBlock = false
      goto continue
    end

    if not isInsideCodeBlock then
      goto continue
    end

    -- переносим комментарии на другую строку
    local comment = codeFragment:match("//.*")
    if comment then
      lines[codeIndex] = comment .. "\n" .. codeFragment:gsub("//.*", "")
      goto continue
    end

    -- vim.notify(codeFragment, vim.log.levels.INFO)
    -- vim.notify(tostring(#codeFragment), vim.log.levels.INFO)

    if #codeFragment < MAX_HOVER_WIDTH_SYMBOLS then
      if codeFragment:match("^%s") then
        indentCode()
        lines[codeIndex] = codeFragment
      end
      goto continue
    end

    local needsMoreFormatting = format(searchWithComma)
    if needsMoreFormatting then
      format(searchWithoutComma)
    end

    if codeFragment:match("^%s") then
      indentCode()
    end

    lines[codeIndex] = codeFragment

    ::continue::
  end

  return lines
end

local function setup_hover_formatting()
  vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
    if not (result and result.contents) then
      return
    end

    local markdown_lines =
      vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    markdown_lines = format_code_in_parentheses(markdown_lines)
    markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)

    if vim.tbl_isempty(markdown_lines) then
      return
    end

    -- настройка попапа с документацией
    config = {
      border = "solid",
      max_width = MAX_HOVER_WIDTH_SYMBOLS,
      max_height = MAX_HOVER_HEIGHT_SYMBOLS,
    }

    vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
  end
end

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import mason_lspconfig plugin
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set(
          "n",
          "<leader>D",
          "<cmd>Telescope diagnostics bufnr=0<CR>",
          opts
        ) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        -- opts.desc = "Show documentation for what is under cursor"
        -- keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs =
      { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["gopls"] = function()
        setup_hover_formatting()
        lspconfig["gopls"].setup({})
      end,
      ["emmet_ls"] = function()
        -- configure emmet language server
        lspconfig["emmet_ls"].setup({
          capabilities = capabilities,
          filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
            "svelte",
          },
        })
      end,
      ["svelte"] = function()
        -- configure svelte server
        lspconfig["svelte"].setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                -- Here use ctx.match instead of ctx.file
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
              end,
            })
          end,
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
    })
  end,
} --]]
