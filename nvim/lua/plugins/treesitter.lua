require('nvim-treesitter').install {
		"bash",
		"lua",
		"python",
		"rust",
		"javascript",
		"zig",
		"go",
		"markdown",
		"markdown_inline",
		"json",
		"toml",
		"typescript",
		"tsx",
		"gotmpl",
		"helm",
		"yaml",
		"java",
	}


-- highlighting
local treesitter_group =
  vim.api.nvim_create_augroup("TreesitterAutostart", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = treesitter_group,
  pattern = "*",
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})



-- folds
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'
