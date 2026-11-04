-- Python debugging via debugpy (installed through mason, see plugins/mason.lua).
-- nvim-dap-python registers the `python`/`debugpy` adapters and default launch
-- configurations, so no manual dap.adapters / dap.configurations setup is needed here.
local dap_python = require("dap-python")
local map = vim.keymap.set

-- The path is the Python that *runs debugpy*, not your project's Python.
-- Your project's interpreter is detected separately (VIRTUAL_ENV, .venv, venv, ...).
dap_python.setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

-- Autocmds run a callback when an event happens. "FileType" fires whenever a
-- buffer's filetype is set, i.e. every time you open a Python file.
vim.api.nvim_create_autocmd("FileType", {
	-- Groups let us clear our own autocmds when this file is re-sourced,
	-- so they don't pile up as duplicates.
	group = vim.api.nvim_create_augroup("dap_python_keymaps", { clear = true }),
	-- Only fire for buffers whose filetype is "python".
	pattern = "python",
	-- `event.buf` is the buffer number that just became a Python buffer.
	callback = function(event)
		-- `buffer = event.buf` makes the mapping exist only in that buffer,
		-- so Go and Python can both use <leader>dt without clashing.

		-- Debug the test method surrounding the cursor
		map("n", "<leader>dt", dap_python.test_method, {
			buffer = event.buf,
			desc = "Debug Nearest Test (Python)",
		})

		-- Debug every test in the class surrounding the cursor
		map("n", "<leader>dT", dap_python.test_class, {
			buffer = event.buf,
			desc = "Debug Test Class (Python)",
		})
	end,
})
