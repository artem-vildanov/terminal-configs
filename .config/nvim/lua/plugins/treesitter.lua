return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  build = ":TSUpdate",
  config = function()
    require("nvim-ts-autotag").setup()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

    -- configure treesitter
    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      auto_install = true,
      sync_install = true,
      -- ensure these language parsers are installed
      ensure_installed = {
        "svelte",
        "json",
        "javascript",
        "typescript",
        "yaml",
        "html",
        "css",
        "markdown",
        "bash",
        "lua",
        "dockerfile",
        "gitignore",
        "go",
        "gomod",
        "gosum",
      },
    })
  end,
}
