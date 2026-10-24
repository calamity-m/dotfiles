-- Lua
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
vim.lsp.enable("lua_ls")

-- Peanutbutter
vim.lsp.config("peanutbutter", {
	cmd = { "peanutbutter", "lsp" },
	filetypes = { "markdown" },
	root_markers = {
		".peanutbutter.toml",
		"peanutbutter.toml",
		"_peanutbutter.toml",
	},
	workspace_required = true,
})
vim.lsp.enable("peanutbutter")

-- Go
vim.lsp.config("gopls", {
	settings = {
		gopls = {
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
})
vim.lsp.enable("gopls")

-- Rust
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			inlayHints = {
				typeHints = {
					enable = true,
				},
				parameterHints = {
					enable = true,
				},
				chainingHints = {
					enable = true,
				},
			},
		},
	},
})
vim.lsp.enable("rust_analyzer")

-- Python
vim.lsp.config("ty", {
	settings = {
		ty = {
			inlayHints = {
				variableTypes = true,
				callArgumentNames = true,
			},
		},
	},
})
vim.lsp.enable("ty")

-- Helm
vim.lsp.config("helm_ls", {
	settings = {
		["helm-ls"] = {
			yamlls = {
				path = "yaml-language-server",
			},
		},
	},
})
vim.filetype.add({
	pattern = {
		[".*/templates/.*%.yaml"] = function(_, bufnr)
			if vim.fs.root(bufnr, { "Chart.yaml" }) then
				return "helm"
			end
			return "yaml"
		end,
		[".*/templates/.*%.yml"] = function(_, bufnr)
			if vim.fs.root(bufnr, { "Chart.yaml" }) then
				return "helm"
			end
			return "yaml"
		end,
		[".*/values%.yaml"] = function(_, bufnr)
			if vim.fs.root(bufnr, { "Chart.yaml" }) then
				return "yaml.helm-values"
			end
			return "yaml"
		end,
		[".*/values%.yml"] = function(_, bufnr)
			if vim.fs.root(bufnr, { "Chart.yaml" }) then
				return "yaml.helm-values"
			end
			return "yaml"
		end,
		[".*/templates/.*%.tpl"] = function(_, bufnr)
			if vim.fs.root(bufnr, { "Chart.yaml" }) then
				return "helm"
			end
		end,
	},
})
vim.lsp.enable("helm_ls")

-- Keymaps
local map = vim.keymap.set

-- We require telescope builtin here, to send lsp items to telescope instead of quickfix list
local telescope_builtin = require("telescope.builtin")

-- Navigation
map("n", "<leader>gd", telescope_builtin.lsp_definitions, { desc = "Go to definition" })
map("n", "<leader>gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "<leader>gi", telescope_builtin.lsp_implementations, { desc = "Go to implementation" })
map("n", "<leader>gc", telescope_builtin.lsp_incoming_calls, { desc = "Go to incoming calls" })
map("n", "<leader>gC", telescope_builtin.lsp_outgoing_calls, { desc = "Go to outgoing calls" })
map("n", "<leader>gy", telescope_builtin.lsp_type_definitions, { desc = "Go to type definition" })
map("n", "<leader>gr", telescope_builtin.lsp_references, { desc = "Find references" })
map("n", "<leader>gs", telescope_builtin.lsp_document_symbols, { desc = "Show symbols in current buffer" })
map("n", "<leader>gS", telescope_builtin.lsp_dynamic_workspace_symbols, { desc = "Show dynamic workspace symbols" })

-- Code actions
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Code rename" })
map("n", "<leader>ce", vim.lsp.codelens.run, { desc = "Code lens" })
map("n", "<leader>cd", telescope_builtin.diagnostics, { desc = "Diagnostics" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

-- Save code without formatting it
vim.api.nvim_create_user_command("WriteNoFormat", function()
	-- Bypass format-on-save autocmds when you need to persist the buffer as-is.
	vim.cmd("noautocmd write")
end, { desc = "Write current file without formatting" })
map("n", "<leader>cW", "<cmd>WriteNoFormat<CR>", { desc = "Write without formatting" })

-- Documentation
map("n", "<leader>gh", vim.lsp.buf.hover, { desc = "Hover documentation" })
