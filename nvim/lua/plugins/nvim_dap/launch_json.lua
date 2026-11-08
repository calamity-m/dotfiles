-- Layered .vscode/launch.json loading for nvim-dap.
--
-- Out of the box nvim-dap only reads <cwd>/.vscode/launch.json. This replaces that
-- with three layers, most specific first:
--   1. relative: nearest .vscode/launch.json above the current file, below the project root
--   2. project:  <project root>/.vscode/launch.json (root = nearest .git, else cwd)
--   3. home:     ~/.vscode/launch.json (personal defaults, available everywhere)
-- If two layers define a config with the same `name`, the more specific one wins.
-- See :help dap-providers-configs
local dap = require("dap")
local vscode = require("dap.ext.vscode")

-- A launch.json `type` is an adapter name. Map it to the filetypes it debugs so that,
-- for example, Go configs in ~/.vscode/launch.json don't show up in Python buffers.
--
-- Only types whose name differs from the filetype need an entry here:
--   "type": "go"      -> not listed, used as-is -> matches filetype "go"
--   "type": "python"  -> not listed, used as-is -> matches filetype "python"
--   "type": "debugpy" -> listed below           -> matches filetype "python"
-- The type must also be a registered adapter (dap.adapters.<type>), or the config will fail to run.
local adapter_filetype_mappings = {
	debugpy = { "python" },
	codelldb = { "rust", "c", "cpp" },
	["pwa-node"] = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	["pwa-chrome"] = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	node = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	chrome = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
}

-- Read one launch.json, returning {} if it is missing or invalid
local function read(path)
	if not vim.uv.fs_stat(path) then
		-- If it's not present exit out here early, nothing to do
		return {}
	end
	-- Read the path and parse into a lua table. vscode.getconfigs is pretty nice.
	-- It allows for comments, returning only confiig and sets up prompts. Doing
	-- vim.json.decode would be pain.
	local ok, configs = pcall(vscode.getconfigs, path)
	if not ok then
		-- If the path was not a valid json file then we'll notify with an error and exit safely
		vim.notify_once(("Failed to read %s:\n%s"):format(path, configs), vim.log.levels.WARN, { title = "DAP" })
		return {}
	end
	return configs
end

-- launch.json paths to check for a buffer, most specific first
local function launch_json_paths(bufnr)
	-- Walk upwards from the current buffer's file until we find a git root, if none can be found then use the cwd
	local project = vim.fs.root(bufnr, ".git") or vim.fn.getcwd()
	-- Get absolute path of current buffer's file
	local file = vim.api.nvim_buf_get_name(bufnr)
	local candidates = {}

	-- 1. Relatve paths.
	--
	-- Walk up from the file's directory, stopping before the project root
	-- (the root itself is layer 2). Skip non-file buffers and files outside the project.
	if vim.startswith(file, project .. "/") then
		for dir in vim.fs.parents(file) do
			if dir == project then
				-- we're at our project root so don't go any further
				break
			end

			local path = dir .. "/.vscode/launch.json"
			if vim.uv.fs_stat(path) then
				-- if the path exists then we've found a valid candidate
				table.insert(candidates, path)
				break
			end
		end
	end

	-- 2. Project root
	table.insert(candidates, project .. "/.vscode/launch.json")
	-- 3. Home directory
	table.insert(candidates, vim.fs.normalize("~/.vscode/launch.json"))

	return candidates
end

-- Called by nvim-dap on <leader>dc (dap.continue) with the current buffer number.
-- Must return a list of configs for the picker.
local function provider(bufnr)
	-- Filetype of the current buffer, e.g. "python"
	local filetype = vim.bo[bufnr].filetype
	-- Config names already kept, so less specific layers can't add a duplicate
	local seen = {}
	local result = {}

	-- Paths are ordered most specific first, so the first config with a given name wins
	for _, path in ipairs(launch_json_paths(bufnr)) do
		for _, config in ipairs(read(path)) do
			-- Which filetypes this config's adapter debugs (defaults to the type itself)
			local filetypes = adapter_filetype_mappings[config.type] or { config.type }
			-- Keep it if we haven't seen this name yet and it's for the current filetype
			if not seen[config.name] and vim.tbl_contains(filetypes, filetype) then
				seen[config.name] = true
				table.insert(result, config)
			end
		end
	end

	return result
end

-- Remove the built-in cwd-only provider, otherwise project configs show up twice
dap.providers.configs["dap.launch.json"] = nil
-- nvim-dap lists providers in alphabetical key order. This key sorts before "dap.global"
-- (the language plugins' defaults), so launch.json configs appear at the top of the picker.
dap.providers.configs["calamity.launch_json"] = provider
