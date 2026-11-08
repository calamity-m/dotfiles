local map = vim.keymap.set

require("tiny-inline-diagnostic").setup({
	preset = "modern",
	options = {
		multilines = {
			enabled = true,
			always_show = true,
			severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
		},
	},
})

-- The plugin draws its own inline diagnostics, so turn off the built-in
-- end-of-line text to avoid showing every message twice.
vim.diagnostic.config({ virtual_text = false })

map("n", "<leader>ti", function()
	require("tiny-inline-diagnostic").toggle()
end, { desc = "Toggle Inline Diagnostics" })
