require('mini.files').setup({
  mappings = {
    close = '<Esc>',
    go_in_plus = '<CR>',
    go_in = '',
  },
})

-- Toggle to showcase explorer
vim.keymap.set("n", "<leader>e", function()
  if MiniFiles.close() == nil then
    MiniFiles.open()
  end
end, {
	desc = "Explorer Toggle",
})

-- Create custom 'go_in' and 'go_out' functions 
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    -- Define a custom go_in, which only allows entering into directories
    local go_in = function()
      local entry = MiniFiles.get_fs_entry()
      -- If the entry exists and is a directory we'll go in, otherwise do nothing
      if entry and entry.fs_type == 'directory' then
        MiniFiles.go_in()
      end
    end

    -- Define a custom go_out which only allows climbing to the reset anchor
    local go_out = function()
      -- Get the lua table state from the explorer, returning early if our state is empty
      local state = MiniFiles.get_explorer_state()
      if not state then return end

      -- Find the focused directory
      local index = state.depth_focus
      local current_directory = state.branch[index]

      -- Check our current directory != our state anchor. If our state anchor is the same
      -- as the current directory, we won't let the explorer go out and do nothing instead.

      if current_directory ~= state.anchor then
        MiniFiles.go_out()
      end
    end

    -- Apply the above functions to multiple keys
    for _, key in ipairs({'l', '<Right>'}) do
      vim.keymap.set('n', key, go_in, {
        buffer = args.data.buf_id,
        desc = 'Enter directory',
      })
    end

    for _, key in ipairs({'h', '<Left>'}) do
      vim.keymap.set('n', key, go_out, {
        buffer = args.data.buf_id,
        desc = 'Leave directory',
      })

    end
  end,
})

