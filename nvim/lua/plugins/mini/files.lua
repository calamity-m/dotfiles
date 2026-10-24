local MiniFiles = require('mini.files')


-- Toggle the explorer, selecting the current file when it exists on disk.
vim.keymap.set("n", "<leader>e", function()
  -- close() returns nil when no explorer was open, so only then do we open one.
  if MiniFiles.close() == nil then
    -- Buffer 0 means the current buffer. Unnamed buffers have an empty path.
    local path = vim.api.nvim_buf_get_name(0)
    local cwd = vim.fn.getcwd()
    -- A branch is an ordered list of paths, each inside the previous directory.
    -- Start with the file and add its parents to the front below.
    local branch = { path }

    -- Only build a branch for an existing, readable file.
    if vim.fn.filereadable(path) == 1 then
      -- ':h' removes the last path component, giving us the parent directory.
      local parent = vim.fn.fnamemodify(path, ':h')
      -- Walk upwards until we reach cwd or the filesystem root.
      -- At the root, asking for the parent returns the same path.
      while parent ~= cwd and parent ~= vim.fn.fnamemodify(parent, ':h') do
        -- Inserting at position 1 keeps the branch ordered from parent to child.
        table.insert(branch, 1, parent)
        parent = vim.fn.fnamemodify(parent, ':h')
      end

      -- Reaching cwd means the file is somewhere inside it.
      -- Example branch: { '/project', '/project/src', '/project/src/main.lua' }.
      if parent == cwd then
        table.insert(branch, 1, cwd)
        -- The opening directory becomes the anchor used by our custom go_out.
        -- Keep that boundary at cwd; false starts fresh instead of restoring history.
        MiniFiles.open(cwd, false)
        -- Including the file positions the directory cursor on its entry.
        -- It also adds a file preview, even with the usual preview option disabled.
        MiniFiles.set_branch(branch)
        -- Remove the final item (the file) and display only the directories.
        -- mini.files remembers the cursor position, so the file stays selected
        -- while its preview disappears. The cwd anchor is unchanged.
        table.remove(branch)
        MiniFiles.set_branch(branch)
        -- Opening is complete; skip the fallback below.
        return
      end
    end

    -- Fallback: a file outside cwd opens with its parent directory as the anchor.
    -- Unnamed buffers and files that aren't readable on disk open at cwd instead.
    -- Lua's `condition and value_a or value_b` selects between these two paths.
    MiniFiles.open(vim.fn.filereadable(path) == 1 and path or cwd, false)
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

-- Git integrations

-- mini.files gives sort() all entries in a directory, but highlight() only one
-- entry at a time. We check Git once in sort(), then let highlight() look up
-- the saved answer here instead of running Git again for every entry.
--
-- This table uses full paths as keys, rather than numeric list positions:
--   ignored['/home/mark/project/nvim.log'] = true
-- A missing key returns nil, which Lua treats as false in an `if` condition.
-- Both callbacks can access this table because it is local to this file,
-- outside either function.
local ignored = {}

-- mini.files calls this with a list of entries from ONE directory.
-- Each entry is a table containing fields such as entry.path and entry.fs_type.
local sort_with_gitignore = function(entries)
  -- #entries is the number of items. With no entries, there is nothing to check
  -- (and no entries[1] from which to work out the parent directory).
  if #entries == 0 then
    return entries
  end

  local paths = {} -- A list of full paths to send to Git in one batch.

  -- ipairs visits each list item, giving us its index and value.
  -- We don't need the index, so use the conventional name `_` to ignore it.
  for _, entry in ipairs(entries) do
    -- Append this entry's full path to our list.
    table.insert(paths, entry.path)

    -- Remove any answer saved for this path on a previous directory read.
    -- Otherwise, a file that stops being ignored could stay dimmed.
    ignored[entry.path] = nil
  end

  -- entries[1] is the first entry (Lua lists start at 1).
  -- fnamemodify(path, ':h') removes the final path component:
  -- '/home/mark/project/nvim.log' becomes '/home/mark/project'.
  -- All these entries share that parent directory.
  local parent = vim.fn.fnamemodify(entries[1].path, ':h')

  -- Run one Git process, passing each command argument as a separate list item:
  --   -C parent     Run Git from this directory, so it finds the right repository.
  --   check-ignore  Report which supplied paths Git ignores.
  --   --stdin       Read those paths from standard input, rather than arguments.
  --   -z            Separate input AND output paths with NUL characters.
  --
  -- '\0' is Lua's escape for a NUL character. Unlike a newline, it cannot occur
  -- in a filename, so it safely separates even filenames containing newlines.
  -- table.concat joins our paths with NULs; .. '\0' adds a final separator.
  -- `stdin = ...` sends that string to the Git process as its input.
  --
  -- vim.system() starts the process. :wait() waits for it to finish and returns
  -- a result table containing its exit code, standard output, and error output.
  local result = vim.system(
    {'git', '-C', parent, 'check-ignore', '--stdin', '-z'},
    { stdin = table.concat(paths, '\0') .. '\0' }
  ):wait()

  -- Git returns code 0 if any supplied paths are ignored, 1 if none are,
  -- and another code for errors (for example, outside a Git repository).
  -- Only parse successful matches; otherwise the cleared entries stay undimmed.
  if result.code == 0 then
    -- stdout contains ONLY ignored paths, separated by NUL characters.
    -- Split it back into a Lua list. trimempty removes the empty item after
    -- the final separator; plain treats the separator as literal text.
    for _, path in ipairs(vim.split(result.stdout, '\0', { trimempty = true, plain = true })) do
      -- Save each answer for the highlight callback to read later.
      ignored[path] = true
    end
  end

  -- This is still a sort callback: return the entries in mini.files' normal
  -- directory-first order. The Git check above only prepares highlighting data.
  return MiniFiles.default_sort(entries)
end



-- MiniFiles setup

MiniFiles.setup({
  mappings = {
    close = '<Esc>',
    go_in_plus = '<CR>',
    go_in = '',
    show_help = '?',
  },
  content = {
    -- Pass the function itself; mini.files will call it with directory entries.
    sort = sort_with_gitignore,

    -- mini.files calls this separately for each entry to choose its highlight.
    highlight = function(entry)
      if ignored[entry.path] then
        -- 'Comment' is a Neovim highlight group, usually muted the theme.
        return 'Comment'
      end

      -- For every other entry, let mini.files choose its usual highlight.
      return MiniFiles.default_highlight(entry)
    end,
  }
})

