local conform = require("conform")

-- Setup conform
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" }, -- Lua formatter
		go = { "goimports", "gofmt" }, -- imports first, then format
		python = { "ruff_organize_imports", "ruff_format" }, -- imports first, then format
		rust = { "rustfmt" }, -- Rust formatter
		proto = { "buf" }, -- Protobuf formatter

		-- Prefer project Prettier config for JS/TS, otherwise use oxfmt.
		javascript = { "prettier", "oxfmt" },
		javascriptreact = { "prettier", "oxfmt" },
		typescript = { "prettier", "oxfmt" },
		typescriptreact = { "prettier", "oxfmt" },
		html = { "oxfmt" },
		css = { "oxfmt" },
		scss = { "oxfmt" },
		json = { "oxfmt" },
		jsonc = { "oxfmt" }, -- JSON with comments (tsconfig, etc.)
		markdown = { "oxfmt" },
		mjs = { "prettier", "oxfmt" }, -- ES modules
		cjs = { "prettier", "oxfmt" }, -- CommonJS modules
		vue = { "prettier", "oxfmt" }, -- mainly script blocks
		toml = { "tombi" }, -- proper TOML formatter
		kdl = { "kdlfmt" }, -- KDL formatter
		xml = { "xmlformatter" }, -- XML formatter
	},

	default_format_opts = {
		lsp_format = "fallback", -- use LSP if no external formatter
	},

	format_on_save = {
		lsp_format = "fallback", -- try external first, fallback to LSP
		timeout_ms = 500, -- prevent long blocking on save
	},
})

-- Setup a "format directory" keymap
vim.api.nvim_create_user_command("ConformDir", function(opts)
	-- Default to the current working directory when no path is provided.
	local dir = opts.args ~= "" and opts.args or vim.fn.getcwd()
	-- glob() returns every path recursively; directories are filtered below.
	local files = vim.fn.glob(dir .. "/**/*", false, true)
	for _, file in ipairs(files) do
		if vim.fn.isdirectory(file) == 0 then
			-- Format through an unloaded buffer so Conform can use buffer-local filetype/options.
			local bufnr = vim.fn.bufadd(file)
			vim.fn.bufload(bufnr)
			-- Run synchronously so the write below persists the formatted contents.
			conform.format({ bufnr = bufnr, async = false, lsp_format = "fallback" })
			vim.api.nvim_buf_call(bufnr, function()
				vim.cmd("silent! write")
			end)
		end
	end
end, { nargs = "?", complete = "dir", desc = "Format all files in a directory" })

vim.keymap.set("n", "<leader>cF", function()
	vim.ui.input({ prompt = "Directory (default cwd): " }, function(input)
		if input == nil then
			return
		end
		vim.cmd("ConformDir " .. (input ~= "" and input or ""))
	end)
end, { desc = "Format directory" })
