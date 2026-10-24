require('telescope').setup({
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown({}),
    },
  },
})

-- Load the telescope-ui-select.nvim plugin
require('telescope').load_extension('ui-select')


-- Define builtin here so it can be used by the custom function
local builtin = require('telescope.builtin')

-- Custom find_files function, which includes gitignored files (barring .git folder itself)
local function find_files_with_ignored()
  -- vim.fn exposes Vim's built-in functions to Lua. getcwd() returns Neovim's
  -- current working directory; both Git and Telescope should search from here.
  local cwd = vim.fn.getcwd()

  -- Use a Lua table as a set: ignored['some/file'] = true lets us quickly
  -- check whether a path is ignored without searching through a list.
  local ignored = {}

  -- Run Git once when the picker opens, instead of once for every file.
  -- Passing arguments as a table avoids shell quoting issues.
  --   --others:           consider untracked files
  --   --ignored:          list ignored files among those untracked files
  --   --exclude-standard: use .gitignore, .git/info/exclude and global ignores
  --   -z:                 separate paths with NUL bytes, so spaces and even
  --                       newlines in filenames are handled correctly
  -- :wait() waits for the command and returns its exit code and output.
  local result = vim.system({
    'git', 'ls-files', '--others', '--ignored', '--exclude-standard', '-z',
  }, { cwd = cwd }):wait()

  -- An exit code of 0 means Git succeeded. Outside a Git repository this
  -- block is skipped, leaving the set empty; hidden-file styling still works.
  if result.code == 0 then
    -- gmatch() iterates over matches in a string. This Lua pattern means
    -- "one or more characters that are not NUL", giving us each Git path.
    for path in result.stdout:gmatch('[^%z]+') do
      ignored[path] = true
    end
  end

  -- A table of options passed to Telescope's find_files picker.
  local opts = {
    cwd = cwd,
    -- Include ignored files and dotfiles in the search results.
    no_ignore = true,
    hidden = true,
    -- Still exclude the repository's internal .git directory. In Lua patterns,
    -- ^ means the start of the string and %. matches a literal dot.
    file_ignore_patterns = {"^%.git/"},
  }

  -- gen_from_file() returns a function that turns a path into a Telescope
  -- "entry": a table containing its searchable value, display function, etc.
  -- Start with Telescope's implementation to keep its normal file behaviour.
  local make_entry = require('telescope.make_entry').gen_from_file(opts)

  -- Telescope calls this function for each result. We build a normal entry,
  -- then customise its display only if the path needs special colouring.
  opts.entry_maker = function(path)
    local entry = make_entry(path)
    -- Some file finders prefix paths with './'. Remove that prefix so paths
    -- match Git's output, and so './ordinary.lua' isn't treated as hidden.
    local relative_path = path:gsub('^%./', '')

    -- A local variable without an initial value is nil (Lua's "no value").
    -- These strings name Neovim highlight groups; your theme sets their colours.
    local highlight
    if ignored[relative_path] then
      highlight = 'Comment'
    -- .. joins strings. Adding '/' lets this detect a dot at the start of
    -- any path component, including '.env' and 'src/.hidden/file.lua'.
    -- elseif gives Git-ignored styling priority when a file is also hidden.
    elseif ('/' .. relative_path):find('/%.') then
      highlight = 'Conceal'
    end

    if highlight then
      -- Save the existing function before replacing it. Calling entry.display
      -- from inside its replacement would otherwise call itself repeatedly.
      local original_display = entry.display
      entry.display = function(e)
        -- Lua functions can return multiple values. Telescope's display function
        -- returns the visible text and a list of highlight ranges for that text.
        local display, highlights = original_display(e)
        -- If there are no existing highlights (nil), use an empty table.
        highlights = highlights or {}
        -- A highlight is { { start_byte, end_byte }, group_name }.
        -- Telescope uses zero-based byte offsets, with the end excluded;
        -- #display is the string's byte length, so this covers the whole row.
        -- Insert it first so existing icon/path highlights can appear on top.
        table.insert(highlights, 1, { { 0, #display }, highlight })
        return display, highlights
      end
    end
    -- Ordinary files keep their original display function.
    return entry
  end

  -- Open the picker using the options and entry-making function above.
  builtin.find_files(opts)
end

-- Keymaps
local map = vim.keymap.set

map('n', '<leader>ff', find_files_with_ignored, { desc = 'Telescope find files' })
map('n', '<leader>F', find_files_with_ignored, { desc = 'Telescope find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- LSP keymaps are set in lspconfig
