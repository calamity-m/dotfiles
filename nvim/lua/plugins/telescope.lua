require("telescope").setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})

-- Load the telescope-ui-select.nvim plugin
require("telescope").load_extension("ui-select")

local builtin = require("telescope.builtin")

-- Keep Telescope's normal entries and layer custom row styling underneath them.
local function find_files(opts, highlight_for_path)
	opts.cwd = vim.fn.getcwd()
	opts.hidden = true
	local make_entry = require("telescope.make_entry").gen_from_file(opts)

	opts.entry_maker = function(path)
		local entry = make_entry(path)
		if not entry then
			return nil
		end

		local relative_path = path:gsub("^%./", "")
		local highlight = highlight_for_path(relative_path)
		if highlight then
			local original_display = entry.display
			entry.display = function(e)
				local display, highlights = original_display(e)
				highlights = highlights or {}
				-- Put row styling first so icon/path highlights can appear on top.
				table.insert(highlights, 1, { { 0, #display }, highlight })
				return display, highlights
			end
		end
		return entry
	end

	builtin.find_files(opts)
end

local function is_hidden(path)
	-- Match a dot at the start of any path component.
	return ("/" .. path):find("/%.") ~= nil
end

local function find_files_with_hidden()
	find_files({
		file_ignore_patterns = { "^%.git/" },
	}, function(path)
		if is_hidden(path) then
			return "Comment"
		end
	end)
end

local function find_files_with_ignored()
	local ignored = {}
	-- Query Git once per picker; NUL separators preserve unusual filenames.
	local result = vim.system({
		"git",
		"ls-files",
		"--others",
		"--ignored",
		"--exclude-standard",
		"-z",
	}, { cwd = vim.fn.getcwd() }):wait()

	-- Outside a repository, fall back to hidden-file styling.
	if result.code == 0 then
		for path in result.stdout:gmatch("[^%z]+") do
			ignored[path] = true
		end
	end

	find_files({
		no_ignore = true,
		file_ignore_patterns = {
			"%.git/",
			"%.venv/",
			"^build/",
			"^target/",
			"%.ruff_cache",
			"%.mypy",
			"__pycache__",
			"%.pytest_cache/",
		},
	}, function(path)
		if ignored[path] then
			return "Comment"
		elseif is_hidden(path) then
			return "Conceal"
		end
	end)
end

-- Keymaps
local map = vim.keymap.set

map("n", "<leader>ff", find_files_with_hidden, { desc = "Telescope find files" })
map("n", "<leader>fF", find_files_with_ignored, { desc = "Telescope find all files" })
map("n", "<leader>F", builtin.find_files, { desc = "Telescope find files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
map("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

-- LSP keymaps are set in lspconfig
