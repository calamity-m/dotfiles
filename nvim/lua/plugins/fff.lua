-- fff handles file finding and live grep; everything else stays on telescope.
require("fff").setup({
  grep = {
    modes = {"plain", "fuzzy", "definition_only"},
  }
})

local map = vim.keymap.set

map("n", "<leader>ff", function()
	require("fff").find_files()
end, { desc = "Find files" })

map("n", "<leader>fg", function()
	require("fff").live_grep()
end, { desc = "Live grep" })

map({ "n", "x" }, "<leader>fw", function()
	require("fff").live_grep_under_cursor()
end, { desc = "Grep word / selection" })
