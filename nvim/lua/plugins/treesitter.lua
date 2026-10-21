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
vim.api.nvim_create_autocmd('FileType', {
  pattern = { '<filetype>' },
  callback = function() vim.treesitter.start() end,
})

-- folds
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'
