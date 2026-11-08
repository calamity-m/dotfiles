-- Taken from :help mini.completions, assists with making Enter more consistent. Needs to be placed early.
_G.cr_action = function()
	-- If there is selected item in popup, accept it with <C-y>
	if vim.fn.complete_info()["selected"] ~= -1 then
		return "\25"
	end
	-- Fall back to plain `<CR>`. You might want to customize according
	-- to other plugins. For example if 'mini.pairs' is set up, replace
	-- next line with `return MiniPairs.cr()`
	return "\r"
end

vim.keymap.set("i", "<CR>", "v:lua.cr_action()", { expr = true })

-- Enable mini completion
local MiniCompletion = require("mini.completion")
MiniCompletion.setup()

-- mini.completion only knows to skip Telescope's prompt. Skip fff's search
-- input too, otherwise it offers buffer words while you type a query.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "fff_input",
	callback = function(args)
		vim.b[args.buf].minicompletion_disable = true
	end,
})

-- Tab selects the next completion; Shift-Tab is reserved for snippet tabstops.
-- Use Ctrl-P for the previous completion.
local imap_expr = function(lhs, rhs)
	vim.keymap.set("i", lhs, rhs, { expr = true })
end
imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
