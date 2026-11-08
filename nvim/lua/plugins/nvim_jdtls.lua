local jdtls = require("jdtls")
local mason_path = vim.fn.stdpath("data") .. "/mason"

-- Prefer repository/build roots so multi-project builds can see settings.gradle,
-- buildSrc, included builds, and sibling modules. Fall back to a standalone build.
local root_markers = { "settings.gradle", "settings.gradle.kts", "gradlew", "mvnw", ".git" }
local fallback_root_markers = { "pom.xml", "build.gradle", "build.gradle.kts" }

local function bundles()
	local result = vim.fn.glob(
		mason_path .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
		false,
		true
	)
	-- These are launched separately by the test extension, not loaded as OSGi bundles.
	local excluded = {
		["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
		["jacocoagent.jar"] = true,
	}
	for _, jar in ipairs(vim.fn.glob(mason_path .. "/packages/java-test/extension/server/*.jar", false, true)) do
		if not excluded[vim.fs.basename(jar)] then
			table.insert(result, jar)
		end
	end
	return result
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("jdtls_setup", { clear = true }),
	pattern = "java",
	callback = function(event)
		-- Use four-space indentation for editing and LSP formatting requests.
		vim.bo[event.buf].expandtab = true
		vim.bo[event.buf].shiftwidth = 4
		vim.bo[event.buf].softtabstop = 4
		vim.bo[event.buf].tabstop = 4

		local root_dir = vim.fs.root(event.buf, root_markers)
			or vim.fs.root(event.buf, fallback_root_markers)
			or vim.fn.getcwd()
		-- A hash keeps repositories with the same basename from sharing JDTLS state.
		local workspace_dir = vim.fn.stdpath("data")
			.. "/jdtls-workspace/"
			.. vim.fs.basename(root_dir)
			.. "-"
			.. vim.fn.sha256(root_dir):sub(1, 8)
		local lombok_path = mason_path .. "/packages/jdtls/lombok.jar"
		local cmd = { mason_path .. "/bin/jdtls", "-data", workspace_dir }
		if vim.fn.filereadable(lombok_path) == 1 then
			-- Lombok is a JVM agent; debug/test extensions go in init_options instead.
			table.insert(cmd, 2, "--jvm-arg=-javaagent:" .. lombok_path)
		end

		jdtls.start_or_attach({
			cmd = cmd,
			root_dir = root_dir,
			settings = { java = { format = { enabled = true } } },
			-- Resolve at startup so packages installed after Neovim starts are picked up.
			init_options = { bundles = bundles() },
			on_attach = function(_, bufnr)
				jdtls.setup_dap({ hotcodereplace = "auto" })

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end
				map("n", "<leader>ci", jdtls.organize_imports, "Organize Imports")
				map("n", "<leader>cev", jdtls.extract_variable, "Extract Variable")
				map("x", "<leader>cev", function()
					jdtls.extract_variable(true)
				end, "Extract Variable")
				map("n", "<leader>cec", jdtls.extract_constant, "Extract Constant")
				map("x", "<leader>cec", function()
					jdtls.extract_constant(true)
				end, "Extract Constant")
				map("x", "<leader>cem", function()
					jdtls.extract_method(true)
				end, "Extract Method")
				map("n", "<leader>dt", jdtls.test_nearest_method, "Debug Nearest Java Test")
				map("n", "<leader>dT", jdtls.test_class, "Debug Java Test Class")
				map("n", "<leader>cju", jdtls.update_projects_config, "Update Java Project Config")
				map("n", "<leader>cjb", function()
					jdtls.compile(true)
				end, "Build Java Project")
			end,
		}, nil, { bufnr = event.buf })
	end,
})
