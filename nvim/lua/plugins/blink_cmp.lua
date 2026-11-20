local cmp = require("blink.cmp")

-- Build rust fuzzy matcher before setup
cmp.build():pwait()

-- Setup blink.cmp
cmp.setup({
	keymap = {
		preset = "enter",
		["<Tab>"] = { "select_next", "fallback" },
		["<C-Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 300,
		},
	},
})
