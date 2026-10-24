local map = vim.keymap.set

-- Helpful clear search and multicursors on escape
vim.keymap.set("n", "<Esc>", function()
  -- Clear search highlighting.
  vim.cmd.nohlsearch()

  -- Get the namespace Neovim uses to store multicursor marks.
  -- Despite the name, create_namespace returns the existing ID if it exists.
  local namespace = vim.api.nvim_create_namespace("nvim.multicursor")

  -- Remove all multicursor marks from the current buffer.
  vim.api.nvim_buf_clear_namespace(
    0,         -- Buffer: 0 means the current buffer.
    namespace, -- Only clear marks belonging to multicursors.
    0,         -- Start at line 0 (the first line).
    -1         -- End at the end of the buffer; -1 is a special sentinel.
  )
end, { desc = "Clear search highlights and multicursors" })

-- Blackhole registers, delete without affecting copy buffer
map("v", "<leader>dd", '"_d', { desc = "Delete Without Yank" })
map("v", "<leader>dc", '"_c', { desc = "Change Without Yank" })
map("n", "x", '"_x', { desc = "Delete Char Without Yank" })
map("v", "p", '"_dP', { desc = "Paste Without Yank Replace" })

-- Neovim troubleshooting
map('n', '<leader>M', '<cmd>messages<CR>', {
  desc = 'Show messages',
})
