-- Snippets in VSCode JSON format, loaded per-language from `snippets/<lang>/*.json` in the config dir.
local MiniSnippets = require("mini.snippets")
local gen_loader = MiniSnippets.gen_loader

MiniSnippets.setup({
	snippets = {
		-- Load snippets based on the current buffer's language (e.g. snippets/rust/*.json)
		gen_loader.from_lang(),
	},
	-- Defaults: <C-j> expand, <C-l>/<C-h> jump next/prev tabstop, <C-c> stop
})

-- Expose snippets as completion items so they show up in the mini.completion popup.
MiniSnippets.start_lsp_server()
