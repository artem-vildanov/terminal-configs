-- убирает все кроме сигнатуры функции из hover
local function setup_hover_cleaner()
  local orig_hover = vim.lsp.handlers["textDocument/hover"]

  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    if result and result.contents then
      local util = vim.lsp.util
      local lines = util.convert_input_to_markdown_lines(result.contents)

      -- Собираем только блоки ```...``` вместе с ```
      local inside_codeblock = false
      local filtered = {}

      for _, line in ipairs(lines) do
        if line:match("^```") then
          inside_codeblock = not inside_codeblock
          table.insert(filtered, line)
        elseif inside_codeblock then
          table.insert(filtered, line)
        end
      end

      -- Если не было кодовых блоков — ничего не показывать
      if vim.tbl_isempty(filtered) then
        return
      end

      -- Показываем только блоки кода
      vim.lsp.util.open_floating_preview(filtered, "markdown", config)
    else
      orig_hover(err, result, ctx, config)
    end
  end
end

local function setup_keymaps(ev)
  local keymap = vim.keymap -- for conciseness

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
  keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

  opts.desc = "Show line diagnostics"
  keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

  opts.desc = "Go to previous diagnostic"
  keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

  opts.desc = "Go to next diagnostic"
  keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

  opts.desc = "Restart LSP"
  keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
end

local function setup_lsp_handlers()
  local lspconfig = require("lspconfig")
  local mason_lspconfig = require("mason-lspconfig")
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  local navic = require("nvim-navic")

  -- autocompletion
  local capabilities = cmp_nvim_lsp.default_capabilities()

  local on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
    end
  end

  mason_lspconfig.setup_handlers({
    -- default handler for installed servers
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end,
    ["pyright"] = function()
      lspconfig["pyright"].setup({
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
        before_init = function(_, config)
          local venv_path = vim.fn.getcwd() .. "/.venv"
          if vim.fn.isdirectory(venv_path) == 1 then
            config.settings.python.pythonPath = venv_path .. "/bin/python"
            config.settings.python.venvPath = "."
          end
        end,
      })
    end,
    ["gopls"] = function()
      lspconfig["gopls"].setup({
        on_attach = on_attach,
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
        on_attach = on_attach,
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
          on_attach(client, bufnr)
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
        on_attach = on_attach,
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

  mason_lspconfig.setup({
    -- list of servers for mason to install
    ensure_installed = {
      "ts_ls",
      "html",
      "cssls",
      "lua_ls",
      "gopls",
    },
  })
end

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile", "VeryLazy" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        setup_keymaps(ev)
        setup_hover_cleaner()
      end,
    })
    setup_lsp_handlers()
  end,
}
