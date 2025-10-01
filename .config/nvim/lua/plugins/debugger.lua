return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "leoluz/nvim-dap-go",
    "nvim-neotest/nvim-nio",
  },

  config = function()
    local dap, dapui = require("dap"), require("dapui")

    require("dapui").setup()
    require("dap-go").setup()

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    local opt = { desc = "Debug" }

    -- Основные действия дебаггера
    opt.desc = "Start/Continue debugging"
    vim.keymap.set("n", "<Leader>dc", dap.continue, opt)

    opt.desc = "Step Over"
    vim.keymap.set("n", "<Leader>do", dap.step_over, opt)

    opt.desc = "Step Into"
    vim.keymap.set("n", "<Leader>di", dap.step_into, opt)

    opt.desc = "Step Out"
    vim.keymap.set("n", "<Leader>dO", dap.step_out, opt) -- Shift + F11

    -- Управление брейкпоинтами
    opt.desc = "Toggle Breakpoint"
    vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, opt)

    opt.desc = "Set Conditional Breakpoint"
    vim.keymap.set("n", "<Leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, opt)

    opt.desc = "List Breakpoints"
    vim.keymap.set("n", "<Leader>dl", dap.list_breakpoints, opt)

    opt.desc = "Clear All Breakpoints"
    vim.keymap.set("n", "<Leader>dC", dap.clear_breakpoints, opt)

    -- Специфичные для языка
    opt.desc = "Debug Nearest Test"
    vim.keymap.set(
      "n",
      "<Leader>dt",
      ":lua require('dap-go').debug_test()<CR>",
      opt
    )

    -- Остальные действия
    opt.desc = "Restart Session"
    vim.keymap.set("n", "<Leader>dr", dap.restart, opt)

    opt.desc = "Terminate Session"
    vim.keymap.set("n", "<Leader>ds", dap.terminate, opt)

    opt.desc = "Pause Debugging"
    vim.keymap.set("n", "<Leader>dp", dap.pause, opt)

    opt.desc = "Open REPL"
    vim.keymap.set("n", "<Leader>dR", dap.repl.open, opt)

    -- Полезные команды
    opt.desc = "Run Last Configuration"
    vim.keymap.set("n", "<Leader>dd", dap.run_last, opt)

    opt.desc = "Show Debugger UI"
    vim.keymap.set("n", "<Leader>du", dapui.toggle, opt) -- если используете nvim-dap-ui

    -- vim.fn.sign_define("DapBreakpoint", {
    --   text = "⏺",
    --   texthl = "DapBreakpoint",
    --   linehl = "DapBreakpoint",
    --   numhl = "DapBreakpoint",
    -- })
  end,
}
