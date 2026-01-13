-- Sessionizer Plugin
-- Fuzzy find and switch to directories under specified paths

return {
  'nvim-telescope/telescope.nvim',
  keys = {
    {
      '<C-f>',
      function()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  -- Specific folders to add directly (depth 0)
  local specific_folders = {
    vim.fn.expand('~\\AppData\\Local\\nvim'),
    vim.fn.expand('~\\AppData\\Roaming\\alacritty'),
  }

  -- Search paths for recursive search
  local search_paths = {
    'C:\\Dev',
    'C:\\Logs',
  }

  -- Get all directories
  local function get_all_dirs()
    local all_dirs = {}
    
    -- Add specific folders first
    for _, folder in ipairs(specific_folders) do
      if vim.fn.isdirectory(folder) == 1 then
        table.insert(all_dirs, folder)
      end
    end
    
    -- Build fd command for search paths with proper quoting
    local cmd_parts = { 'fd', '--type', 'd', '--max-depth', '1', '--hidden', '--exclude', '.git' }
    for _, path in ipairs(search_paths) do
      table.insert(cmd_parts, '--search-path')
      table.insert(cmd_parts, '"' .. path .. '"')
    end
    
    local cmd = table.concat(cmd_parts, ' ')
    
    -- Execute fd and add results
    local handle = io.popen(cmd)
    if handle then
      for line in handle:lines() do
        -- Trim whitespace and remove trailing backslashes
        line = line:match("^%s*(.-)%s*$")
        line = line:gsub("\\+$", "")
        
        if line and line ~= '' and vim.fn.isdirectory(line) == 1 then
          table.insert(all_dirs, line)
        end
      end
      handle:close()
    end
    
    return all_dirs
  end

  pickers.new({}, {
    prompt_title = 'Sessionizer - Select Directory',
    finder = finders.new_table {
      results = get_all_dirs(),
      entry_maker = function(entry)
        local display_name = vim.fn.fnamemodify(entry, ':t')
        return {
          value = entry,
          display = display_name ~= '' and display_name or entry,
          ordinal = entry,
          path = entry,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if selection then
          local dir = selection.path

          -- Save current session before switching (before closing buffers!)
          vim.cmd 'silent! AutoSession save'

          -- Close all buffers
          vim.cmd 'silent! %bdelete'

          -- Change directory
          vim.cmd('cd ' .. vim.fn.fnameescape(dir))

          -- Small delay to ensure directory change is complete
          vim.defer_fn(function()
            -- Get current directory and manually escape it using URL encoding
            local cwd = vim.fn.getcwd()
            local clean_cwd = cwd:gsub('\\+$', '') -- Remove trailing backslash
            -- Encode special characters: backslash, colon, dot, and space
            local escaped = clean_cwd:gsub('\\', '%%5C'):gsub(':', '%%3A'):gsub('%.', '%%2E'):gsub(' ', '%%20')

            local session_root = vim.fn.stdpath 'data' .. '/sessions/'
            local session_file = session_root .. escaped .. '.vim'

            -- Check if session file exists
            if vim.fn.filereadable(session_file) == 1 then
              -- Session exists, restore it
              vim.cmd 'silent! AutoSession restore'
            else
              -- No session exists, open oil
              require('oil').open(dir)
            end
          end, 100)
        end
      end)

      return true
    end,
  }):find()
      end,
      desc = 'Sessionizer - Find and switch to directory',
    },
  },
}