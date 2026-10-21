
vim.pack.add({
  -- Core plugins
  { src = "https://github.com/folke/which-key.nvim" },
  -- Base16 theme support for the Noctalia/Matugen template
  { src = "https://github.com/RRethy/base16-nvim" },
  -- Mini plugin pack
  { src = "https://github.com/nvim-mini/mini.nvim" }, 

})

local plugin_modules = {
	"plugins.which_key",
  "plugins.mini",
}

for _, module in ipairs(plugin_modules) do
	require(module)
end
