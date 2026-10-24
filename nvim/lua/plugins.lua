

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

  -- Editor
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
})

local plugin_modules = {
  "plugins.which_key",
  "plugins.mini",
  "plugins.treesitter",
  "plugins.telescope",
  "plugins.mason",
  "plugins.lspconfig",
}

for _, module in ipairs(plugin_modules) do
	require(module)
end
