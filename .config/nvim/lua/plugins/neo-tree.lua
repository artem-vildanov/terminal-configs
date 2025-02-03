return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local TreePosition = {
      LEFT = "left",
      FLOAT = "float",
    }

    local tree_position = TreePosition.FLOAT

    local function toggle_tree_position()
      if tree_position == TreePosition.LEFT then
        tree_position = TreePosition.FLOAT
      else
        tree_position = TreePosition.LEFT
      end
      vim.notify("Tree position is now: " .. tree_position)
    end

    require("neo-tree").setup({
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_hidden = true, -- only works on Windows for hidden files/directories
        },
      },
      window = {
        position = TreePosition.FLOAT,
        mappings = {
          ["<CR>"] = "open",
          ["t"] = "open_tabnew",
        },
      },
    })

    vim.keymap.set("n", "<leader>eb", function()
      return "<cmd>Neotree buffers reveal " .. tree_position .. "<CR>"
    end, {
      desc = "Reveal open buffers",
      expr = true,
    })
    vim.keymap.set("n", "<leader>ee", function()
      return "<cmd>Neotree filesystem reveal " .. tree_position .. "<CR>"
    end, {
      desc = "Reveal file explorer",
      expr = true,
    })
    vim.keymap.set(
      "n",
      "<leader>ec",
      "<cmd>Neotree focus<CR>",
      { desc = "Focus file explorer" }
    )
    vim.keymap.set(
      "n",
      "<leader>er",
      "<cmd>Neotree refresh<CR>",
      { desc = "Refresh file explorer" }
    )
    vim.keymap.set(
      "n",
      "<leader>ep",
      toggle_tree_position,
      { desc = "Toggle Neo-tree position" }
    )
  end,
}
