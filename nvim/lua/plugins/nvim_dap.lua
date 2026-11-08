local dap = require("dap")
local map = vim.keymap.set

--- Signs (the defaults are not very pretteh)
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })

-- Session control
map("n", "<leader>dc", dap.continue, { desc = "Continue / Start" })
map("n", "<leader>dn", dap.step_over, { desc = "Step Over" })
map("n", "<leader>di", dap.step_into, { desc = "Step Into" })
map("n", "<leader>do", dap.step_out, { desc = "Step Out" })
map("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to Cursor" })
map("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
map("n", "<leader>dq", dap.terminate, { desc = "Terminate" })
map("n", "<leader>dr", dap.restart, { desc = "Restart" })

-- Breakpoints
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Conditional Breakpoint" })
map("n", "<leader>dL", function()
	dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end, { desc = "Log Point" })
map("n", "<leader>dX", dap.clear_breakpoints, { desc = "Clear Breakpoints" })

-- Layered .vscode/launch.json (home, project, relative)
require("plugins.nvim_dap.launch_json")

-- Languages
require("plugins.nvim_dap.go")
require("plugins.nvim_dap.js")
require("plugins.nvim_dap.python")
require("plugins.nvim_dap.rust")
