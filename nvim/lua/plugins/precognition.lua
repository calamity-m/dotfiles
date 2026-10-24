local map = vim.keymap.set

require("precognition").setup({
	startVisible = false,
})

map("n", "<leader>tp", function()
	require("precognition").toggle()
end, { desc = "Toggle Precognition" })
