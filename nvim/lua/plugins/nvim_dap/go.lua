-- Go debugging via delve (installed through mason, see plugins/mason.lua).
-- nvim-dap-go registers the `go` adapter and default launch configurations,
-- so no manual dap.adapters / dap.configurations setup is needed here.
local dap_go = require("dap-go")
local map = vim.keymap.set

dap_go.setup()

-- Test keymaps are buffer-local so other languages can reuse <leader>dt/dT.
-- The augroup (cleared on re-source) prevents duplicate autocmds.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("dap_go_keymaps", { clear = true }),
	pattern = "go",
	callback = function(event)
		-- Debug the test function surrounding the cursor
		map("n", "<leader>dt", dap_go.debug_test, {
			buffer = event.buf,
			desc = "Debug Nearest Test (Go)",
		})

		-- Re-run whichever test was last debugged with debug_test
		map("n", "<leader>dT", dap_go.debug_last_test, {
			buffer = event.buf,
			desc = "Debug Last Test (Go)",
		})
	end,
})
