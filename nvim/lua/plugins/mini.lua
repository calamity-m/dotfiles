-- Pre-requisites
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

-- mini submodules
require("plugins.mini.files")
require("plugins.mini.completions")
require("plugins.mini.statuscolumn")
require("plugins.mini.git")
require("plugins.mini.diff")
require("plugins.mini.jump2d")

-- direct mini setup
require("mini.tabline").setup()
require("mini.statusline").setup()
require("mini.cursorword").setup()
require("mini.cmdline").setup()
require("mini.notify").setup()
require("mini.indentscope").setup()
require("mini.splitjoin").setup({
	mappings = {
		toggle = "<leader>cs",
	},
})
