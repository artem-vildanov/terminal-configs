local MAX_HOVER_WIDTH_SYMBOLS = 50
local MAX_HOVER_HEIGHT_SYMBOLS = 15

---@param code_fragment string
---@param search_start integer
---@param should_contain_comma boolean
---@return nil | integer
---@return nil | integer
local function search_in_parentheses(
  code_fragment,
  search_start,
  should_contain_comma
)
  local pos = search_start or 1

  while true do
    local old_substring_start, old_substring_end =
      code_fragment:find("%b()", pos)
    if not old_substring_start then
      return nil, nil
    end

    local inside =
      code_fragment:sub(old_substring_start + 1, old_substring_end - 1)
    local has_comma = inside:find(",", 1, true)

    if
      (should_contain_comma and has_comma)
      or (not should_contain_comma and not has_comma)
    then
      return old_substring_start, old_substring_end
    end

    pos = old_substring_end + 1
  end
end

---@param code_fragment string
---@param get_substring_start_end function
---@return string
---@return boolean
local function format_code_fragment(code_fragment, get_substring_start_end)
  local search_start = 1
  local should_format_beginning = false

  local first_substring_start, _ =
    get_substring_start_end(search_start, code_fragment)

  vim.notify(tostring(first_substring_start))

  if first_substring_start > MAX_HOVER_WIDTH_SYMBOLS then
    should_format_beginning = true
  end

  while true do
    local old_substring_start, old_substring_end =
      get_substring_start_end(search_start, code_fragment)
    if not old_substring_start then
      return code_fragment, true
    end

    local old_substring =
      code_fragment:sub(old_substring_start, old_substring_end)
    vim.notify(old_substring)
    local new_substring =
      old_substring:gsub("%(", "(\n  "):gsub(",%s*", ",\n  "):gsub("%)", "\n)")
    vim.notify(new_substring)

    code_fragment = code_fragment:sub(1, old_substring_start - 1)
      .. new_substring
      .. code_fragment:sub(old_substring_end + 1)

    local _, new_substring_end = code_fragment:find(new_substring)

    if #code_fragment - new_substring_end < MAX_HOVER_WIDTH_SYMBOLS then
      if should_format_beginning then
        return code_fragment, true
      end

      vim.notify("early")
      return code_fragment, false
    end

    -- local new_substring_end = old_substring_start + #new_substring
    --
    -- if #code_fragment - new_substring_end < MAX_HOVER_WIDTH_SYMBOLS then
    --   return code_fragment, false
    -- end

    search_start = old_substring_end + 1
  end
end

---@param code_fragment string
---@return string
---@return boolean
local function format_code_with_commas(code_fragment)
  return format_code_fragment(
    code_fragment,
    function(search_start, updated_code_fragment)
      return search_in_parentheses(updated_code_fragment, search_start, true)
    end
  )
end

---@param code_fragment string
---@return string
local function format_code_without_commas(code_fragment)
  local code, _ = format_code_fragment(
    code_fragment,
    function(search_start, updated_code_fragment)
      return search_in_parentheses(updated_code_fragment, search_start, false)
    end
  )
  return code
end

---@param code_fragment string
---@return string
local function indent_code(code_fragment)
  local code, _ = code_fragment:gsub("\n", "\n  "):gsub("^%s+", "  ")
  return code
end

---@param lines table
---@return table
local function format_code_in_parentheses(lines)
  local is_inside_code_block = false

  for code_index, code_fragment in ipairs(lines) do
    if code_fragment == "```go" then
      is_inside_code_block = true
    elseif code_fragment == "```" then
      is_inside_code_block = false
    end

    if not is_inside_code_block then
      goto continue
    end

    local comment = code_fragment:match("//.*")
    if comment then
      lines[code_index] = comment .. "\n" .. code_fragment:gsub("//.*", "")
      goto continue
    end

    if #code_fragment < MAX_HOVER_WIDTH_SYMBOLS then
      if code_fragment:match("^%s") then
        lines[code_index] = indent_code(code_fragment)
      end
      goto continue
    end

    local formatted_code, needs_more_formatting =
      format_code_with_commas(code_fragment)
    code_fragment = formatted_code
    if needs_more_formatting then
      code_fragment = format_code_without_commas(code_fragment)
    end

    lines[code_index] = code_fragment

    if code_fragment:match("^%s") then
      lines[code_index] = indent_code(code_fragment)
    end

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
        lspconfig["gopls"].setup({
          settings = {
            gopls = {
              buildFlags = { "-tags=integration" },
            },
          },
        })
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
