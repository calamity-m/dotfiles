require("options")
require("plugins")
require("keybinds")

local ok, matugen = pcall(require, 'matugen')
if ok then matugen.setup() end
