-- Helper functions and mappings for managing vim.pack - not for actual plugin installation. Look @ plugins.lua for that.

local map = vim.keymap.set

map("n", "<leader>vpu", function()
	vim.pack.update()
end, { desc = "Update Plugins" })

map("n", "<leader>vpl", function()
	vim.pack.update(nil, { offline = true })
end, { desc = "List Plugins" })

map("n", "<leader>vpd", function()
	local inactive = vim.iter(vim.pack.get())
		:filter(function(plugin)
			return not plugin.active
		end)
		:map(function(plugin)
			return plugin.spec.name
		end)
		:totable()

	if #inactive == 0 then
		vim.notify("No inactive plugins to delete", vim.log.levels.INFO)
		return
	end

	vim.ui.select({ "Delete", "Cancel" }, {
		prompt = "Delete inactive plugins: " .. table.concat(inactive, ", ") .. "?",
	}, function(choice)
		if choice == "Delete" then
			vim.pack.del(inactive)
		end
	end)
end, { desc = "Delete Inactive Plugins" })
