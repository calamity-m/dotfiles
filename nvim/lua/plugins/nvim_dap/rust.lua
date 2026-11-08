-- Rust (and C/C++) debugging via codelldb (installed through mason, see plugins/mason.lua).
-- There's no nvim-dap-* plugin for this, so we register the adapter ourselves.
local dap = require("dap")
local map = vim.keymap.set

-- An adapter tells nvim-dap how to start the debugger.
-- The key ("codelldb") is the name configs use in their "type" field.
dap.adapters.codelldb = {
	-- "executable": nvim-dap starts the program and talks to it over stdin/stdout
	-- (supported by codelldb 1.11+)
	type = "executable",
	-- Found on PATH because mason adds its bin folder to PATH
	command = "codelldb",
}

-- Below here we enable <leader>dt to get DAP with highlighted test or test module

-- Read the human-readable compiler diagnostics from Cargo's JSON output.
local function parse_cargo_errors(stdout)
	local errors = {}

	for line in vim.gsplit(stdout or "", "\n", { trimempty = true }) do
		local ok, message = pcall(vim.json.decode, line)

		if ok and message.reason == "compiler-message" and message.message.level == "error" then
			table.insert(errors, message.message.rendered)
		end
	end

	return errors
end

-- Collect the test executable paths reported by cargo test --no-run.
-- Cargo can produce several: library tests, binary tests, and integration tests.
local function parse_test_binaries(stdout)
	local binaries = {}

	-- Cargo writes one JSON object per line, rather than one big JSON document.
	for line in vim.gsplit(stdout or "", "\n", { trimempty = true }) do
		-- pcall lets us skip any line that isn't valid JSON.
		-- Convert JSON null to Lua nil so missing executable paths are falsy.
		local ok, message = pcall(vim.json.decode, line, {
			luanil = { object = true },
		})

		-- Keep only build artifacts that are test executables.
		-- Other messages describe diagnostics or artifacts such as libraries.
		if ok and message.reason == "compiler-artifact" and message.profile.test and message.executable then
			table.insert(binaries, {
				path = message.executable,
				label = message.target.name .. " (" .. table.concat(message.target.kind, ", ") .. ")",
			})
		end
	end

	return binaries
end

-- Find the enclosing function/module and turn its name into a test filter.
local function get_test_filter(bufnr)
	local node = vim.treesitter.get_node()
	if not node then
		vim.notify("No syntax node found")
		return
	end

	-- Walk up our parents until we find a surrounding function or module.
	while node and node:type() ~= "function_item" and node:type() ~= "mod_item" do
		node = node:parent()
	end

	if not node then
		vim.notify("Not inside a function or module")
		return
	end

	local name_node = node:field("name")[1]
	local name = vim.treesitter.get_node_text(name_node, bufnr)
	local parts = { name }
	local ancestor = node:parent()

	while ancestor do
		if ancestor:type() == "mod_item" then
			local module_node = ancestor:field("name")[1]
			local module_name = vim.treesitter.get_node_text(module_node, bufnr)
			table.insert(parts, 1, module_name)
		end

		ancestor = ancestor:parent()
	end

	local filename = vim.api.nvim_buf_get_name(bufnr)
	-- :t keeps only the filename; :r removes its extension.
	local stem = vim.fn.fnamemodify(filename, ":t:r")

	-- Approximate the module path using the filename.
	-- Skip lib/main/mod, since those filenames aren't module names.
	if stem ~= "lib" and stem ~= "main" and stem ~= "mod" then
		table.insert(parts, 1, stem)
	end

	local filter = table.concat(parts, "::")
	if node:type() == "mod_item" then
		-- Include tests inside this module, not similarly named modules.
		filter = filter .. "::"
	end

	return filter
end

-- Build asynchronously, then pass the parsed executables to on_built.
-- On failure, show diagnostics and stop here instead.
local function build_test_binaries(on_built)
	vim.notify("Building tests...")

	vim.system({ "cargo", "test", "--no-run", "--message-format=json" }, { text = true }, function(result)
		-- Keep UI work and the next step on Neovim's main loop.
		vim.schedule(function()
			if result.code ~= 0 then
				local errors = parse_cargo_errors(result.stdout)
				local details = table.concat(errors, "\n")

				if details == "" then
					details = result.stderr
				end

				vim.notify(details, vim.log.levels.ERROR)
				return
			end

			on_built(parse_test_binaries(result.stdout))
		end)
	end)
end

-- A matching test is listed as "module::test_name: test".
local function contains_listed_test(stdout)
	for line in vim.gsplit(stdout or "", "\n") do
		if line:match(": test%s*$") then
			return true
		end
	end

	return false
end

-- Ask each executable which tests match the filter, without running the tests.
-- Call on_checked only after every asynchronous check has finished.
local function find_matching_binaries(binaries, filter, on_checked)
	local matches = {}
	local remaining = #binaries

	if remaining == 0 then
		vim.notify("Cargo produced no test executables")
		return
	end

	for _, binary in ipairs(binaries) do
		vim.system({ binary.path, filter, "--list" }, { text = true }, function(result)
			vim.schedule(function()
				if result.code == 0 then
					if contains_listed_test(result.stdout) then
						table.insert(matches, binary)
					end
				else
					vim.notify(
						"Could not list tests for " .. binary.label .. "\n" .. (result.stderr or ""),
						vim.log.levels.WARN
					)
				end

				-- Scheduled callbacks run one at a time, so these updates don't overlap.
				remaining = remaining - 1
				if remaining == 0 then
					on_checked(matches)
				end
			end)
		end)
	end
end

-- Launch only when exactly one executable matches the requested test/module.
local function debug_matching_binary(matches, filter)
	if #matches == 0 then
		vim.notify("No test executable matched: " .. filter, vim.log.levels.WARN)
		return
	end

	if #matches > 1 then
		vim.notify("Multiple test executables matched; selection needed", vim.log.levels.WARN)
		return
	end

	-- Show println! output and run tests one at a time for easier debugging.
	local test_args = { filter, "--nocapture", "--test-threads=1" }

	vim.notify("Running test executable for " .. filter)
	dap.run({
		name = "Debug " .. filter,
		type = "codelldb",
		request = "launch",
		program = matches[1].path,
		args = test_args,
		cwd = vim.fn.getcwd(),
	})
end

-- The overall flow: cursor -> filter -> build -> find matches -> debug.
local function debug_test_at_cursor(bufnr)
	local filter = get_test_filter(bufnr)
	if not filter then
		return
	end

	build_test_binaries(function(binaries)
		find_matching_binaries(binaries, filter, function(matches)
			debug_matching_binary(matches, filter)
		end)
	end)
end

-- Same pattern as go.lua / python.lua: buffer-local keymaps for Rust files only.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("dap_rust_keymaps", { clear = true }),
	pattern = "rust",
	callback = function(event)
		map("n", "<leader>dt", function()
			debug_test_at_cursor(event.buf)
		end, {
			buffer = event.buf,
			desc = "Debug Rust Test",
		})
	end,
})
