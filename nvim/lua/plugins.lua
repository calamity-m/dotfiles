-- Build hooks must be registered before vim.pack.add so they fire on first install.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "fff" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("fff")
			end
			-- Downloads a prebuilt binary, or falls back to cargo build
			require("fff.download").download_or_build_binary()
		end
	end,
})

vim.pack.add({
	-- Core plugins
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	-- Base16 theme support for the Noctalia/Matugen template
	{ src = "https://github.com/RRethy/base16-nvim" },
	-- Mini plugin pack
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	-- IDE/LSP plugins
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	-- DAP Core
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/igorlfs/nvim-dap-view" },
	-- DAP Language Support
	{ src = "https://github.com/leoluz/nvim-dap-go" },
	{ src = "https://github.com/mfussenegger/nvim-dap-python" },
	-- Good ol' java
	{ src = "https://github.com/mfussenegger/nvim-jdtls" },
	-- Editor plugins
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/dmtrKovalenko/fff" },
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
	-- Trial plugins
	{ src = "https://github.com/tris203/precognition.nvim" },
})

local plugin_modules = {
	"plugins.which_key",
	"plugins.mini",
	"plugins.treesitter",
	"plugins.telescope",
	"plugins.fff",
	"plugins.mason",
	"plugins.lspconfig",
	"plugins.tiny_inline_diagnostic",
	"plugins.conform",
	"plugins.precognition",
	"plugins.nvim_dap",
	"plugins.nvim_dap_view",
	"plugins.nvim_jdtls",
}

for _, module in ipairs(plugin_modules) do
	require(module)
end
