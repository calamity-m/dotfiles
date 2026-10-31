local MiniNotify = require("mini.notify")

MiniNotify.setup()

vim.keymap.set("n", "<leader>hMn", MiniNotify.show_history, { desc = "Show Notification History" })
