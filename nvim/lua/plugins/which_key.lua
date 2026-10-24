local wk = require("which-key")

wk.setup({
	preset = "helix",
	delay = 300,
	icons = {
		mappings = false,
	},
})

wk.add({
	{ "<leader>c", group = "Code" },
	{ "<leader>f", group = "Telescope" },
	{ "<leader>g", group = "Search LSP" },
	{ "<leader>t", group = "Toggle" },
})

-- Multicursors
wk.add({
	{ "<leader>m", group = "Multicursor" },
	{ "<leader>mt", "Q", desc = "Toggle cursor here" },
	{ "<leader>mw", "zq*", desc = "Cursors at every matching word" },
	{ "<leader>mr", "gQ", desc = "Restore cleared cursors" },
	{
		"<leader>mh",
		"<cmd>help multicursor<CR>",
		desc = "Multicursor help",
	},
})
