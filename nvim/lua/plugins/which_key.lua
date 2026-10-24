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
})
