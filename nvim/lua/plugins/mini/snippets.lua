-- Snippets in VSCode JSON format, loaded per-language from `snippets/<lang>/*.json` in the config dir.
local MiniSnippets = require("mini.snippets")
local gen_loader = MiniSnippets.gen_loader

MiniSnippets.setup({
	snippets = {
		-- Load snippets based on the current buffer's language (e.g. snippets/rust/*.json)
		gen_loader.from_lang(),
	},
	mappings = {
		jump_next = "<C-Tab>",
		jump_prev = "<S-Tab>",
	},
	-- Keep defaults: <C-j> expand, <C-c> stop
})

-- Finish immediately when jumping to the final ($0) tabstop, removing its marker.
vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("snippet_final_tabstop", { clear = true }),
	pattern = "MiniSnippetsSessionJump",
	callback = function(args)
		if args.data.tabstop_to == "0" then
			MiniSnippets.session.stop()
		end
	end,
})

-- Expose snippets as completion items so they show up in the mini.completion popup.
MiniSnippets.start_lsp_server()
