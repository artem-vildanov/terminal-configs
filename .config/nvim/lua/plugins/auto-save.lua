return {
	"pocco81/auto-save.nvim",
	config = function()
		require("auto-save").setup({
			enabled = true,
			debounce_delay = 300,
			conditions = {
				exists = true,
				filename_is_not = {}, -- файлы, которые не нужно сохранять
				filetype_is_not = {}, -- типы файлов, которые не нужно сохранять
				modifiable = true,
			},
			write_all_buffers = false, -- сохранять только текущий буфер
			on_off_commands = true, -- создать команды AutoSaveEnable/AutoSaveDisable
      clean_command_line_interval = 0, -- очистка сообщений в командной строке
    })

		vim.api.nvim_set_keymap("n", "<leader>at", ":ASToggle<CR>", { desc = "Toggle autosave" })
	end,
}
