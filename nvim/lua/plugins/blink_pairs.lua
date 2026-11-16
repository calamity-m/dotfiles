local pairs = require("blink.pairs")

pairs.build():pwait(60000)

pairs.setup({
	highlights = {
		enabled = true,
		-- Keep rainbow nesting colours in sync with the current theme.
		groups = { "Constant", "Statement", "Function" },
		separate = { "<" },
		unmatched_group = "DiagnosticError",
		matchparen = {
			enabled = true,
			cmdline = false,
			include_surrounding = false,
			group = "MatchParen",
			priority = 250,
		},
	},
})
