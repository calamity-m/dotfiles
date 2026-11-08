local dap = require("dap")

-- Mason's wrapper starts vscode-js-debug's DAP server (Node must be on PATH).
for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
	dap.adapters[adapter] = {
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		executable = {
			command = "js-debug-adapter",
			args = { "${port}" },
		},
	}
end

-- Support the modern VS Code launch.json names too.
for alias, adapter in pairs({ node = "pwa-node", chrome = "pwa-chrome" }) do
	dap.adapters[alias] = function(callback, config)
		config.type = adapter
		callback(dap.adapters[adapter])
	end
end

for _, filetype in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
	dap.configurations[filetype] = {
		{
			name = "Node: launch current file (JavaScript)",
			type = "pwa-node",
			request = "launch",
			program = "${file}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			skipFiles = { "<node_internals>/**" },
			console = "integratedTerminal",
		},
		{
			name = "Node: attach to process",
			type = "pwa-node",
			request = "attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			skipFiles = { "<node_internals>/**" },
		},
		{
			name = "Chrome: launch localhost",
			type = "pwa-chrome",
			request = "launch",
			url = function()
				return vim.fn.input("Dev server URL: ", "http://localhost:5173")
			end,
			webRoot = "${workspaceFolder}",
			sourceMaps = true,
		},
	}
end
