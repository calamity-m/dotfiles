local map = vim.keymap.set

-- Helpful clear search on escape
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })

-- Blackhole registers, delete without affecting copy buffer
map("v", "<leader>dd", '"_d', { desc = "Delete Without Yank" })
map("v", "<leader>dc", '"_c', { desc = "Change Without Yank" })
map("n", "x", '"_x', { desc = "Delete Char Without Yank" })
map("v", "p", '"_dP', { desc = "Paste Without Yank Replace" })

-- Neovim troubleshooting
map('n', '<leader>M', '<cmd>messages<CR>', {
  desc = 'Show messages',
})
