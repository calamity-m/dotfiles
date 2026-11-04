local dap_view = require("dap-view")
dap_view.setup({
	-- "open": open the view when a session starts, but leave it open when the session ends
	auto_toggle = "open",
	winbar = {
		sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
	},
})
local map = vim.keymap.set
map("n", "<leader>td", "<cmd>DapViewToggle!<CR>", { desc = "DAP View Toggle" })
map("n", "<leader>dvh", "<cmd>DapViewHover<CR>", { desc = "DAP View Hover" })
map("v", "<leader>dvh", "<cmd>DapViewHover<CR>", { desc = "DAP View Hover Selection" })
