-- Pre-requisites
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

-- mini submodules
require("plugins.mini.files")
require("plugins.mini.completions")
require("plugins.mini.statuscolumn")
require("plugins.mini.git")
require("plugins.mini.diff")

-- direct mini setup
require("mini.tabline").setup()
require("mini.statusline").setup()
