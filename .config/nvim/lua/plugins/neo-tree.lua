local a = {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function ()
      require("neo-tree").setup({
        window = {
          number = true,
          relativenumber = true,
          position = "float",
          mappings = {
            ["<CR>"] = "open",
            ["t"] = "open_tabnew",
          }
        },
      })
      vim.wo.number = true
      vim.wo.relativenumber = true

      -- Key mappings for Neo-tree
      vim.keymap.set("n", "<leader>ee", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })
      vim.keymap.set("n", "<leader>eb", "<cmd>Neotree buffers toggle<CR>", { desc = "Toggle open buffers" })
      vim.keymap.set("n", "<leader>ef", "<cmd>Neotree reveal<CR>", { desc = "Reveal current file in file explorer" })
      vim.keymap.set("n", "<leader>ec", "<cmd>Neotree focus<CR>", { desc = "Focus file explorer" }) -- Neo-tree auto-collapses other nodes by default
      vim.keymap.set("n", "<leader>er", "<cmd>Neotree refresh<CR>", { desc = "Refresh file explorer" })
    end
}
return {}
