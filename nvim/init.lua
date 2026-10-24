require("options")
require("plugins")
require("keybinds")
require("vimpack")

-- Theme setup with noctalia
local ok, matugen = pcall(require, "matugen")
if ok then
	matugen.setup()
end

-- Let the terminal's background show through these parts of Neovim.
-- The terminal and compositor provide the actual opacity and blur.
local function transparent_background()
	-- Each name is a highlight group controlling a particular part of the UI.
	for _, group in ipairs({
		"Normal", -- Text and background in the active window.
		"NormalNC", -- Text and background in inactive windows.
		"SignColumn", -- Gutter containing diagnostic and Git signs.
		"EndOfBuffer", -- Empty lines below the end of a file.
		"NormalFloat", -- Default background of floating windows.
		"FloatBorder", -- Borders around floating windows.
	}) do
		-- Read the group's current colours and styling (0 = global highlights).
		-- Resolve linked groups so their foreground and styling are preserved too.
		local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
		-- Remove only the background colour, keeping everything else.
		hl.bg = nil
		vim.api.nvim_set_hl(0, group, hl)
	end
end

-- A colourscheme can restore opaque backgrounds, so clear them again when
-- Neovim fires ColorScheme. Schedule this to run after theme setup finishes.
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.schedule(transparent_background)
	end,
})

-- Apply once now: the initial Matugen setup above has already finished.
transparent_background()
