require("options")
require("plugins")
require("keybinds")
require("vimpack")

local ok, matugen = pcall(require, "matugen")
if ok then
	matugen.setup()
end
