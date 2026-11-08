require("options")
require("plugins")
require("keybinds")
require("vimpack")
require("theme")

local ok, matugen = pcall(require, 'matugen')
if ok then matugen.setup() end
