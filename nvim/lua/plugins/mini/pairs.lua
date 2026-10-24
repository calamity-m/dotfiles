local MiniPairs = require("mini.pairs")

MiniPairs.setup({
	mappings = {
		-- Only open a quote pair when neither adjacent character is a word character.
		['"'] = { neigh_pattern = "^[^%w_\\][^%w_]" },
	},
})
