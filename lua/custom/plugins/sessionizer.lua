-- Sessionizer Plugin
-- Fuzzy find and switch to directories under specified paths

return {
  'nvim-telescope/telescope.nvim',
  keys = {
    {
      '<C-f>',
      function()
        local telescope = require('telescope.builtin')
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        
        -- Search paths
        local search_paths = {
          'C:\\Dev',
          'C:\\Logs',
        }
        
        -- Build find command for Windows - limit to immediate subdirectories only
        local find_command = { 'fd', '--type', 'd', '--max-depth', '1', '--hidden', '--exclude', '.git' }
        
        -- Add search paths
        for _, path in ipairs(search_paths) do
          table.insert(find_command, '--search-path')
          table.insert(find_command, path)
        end
        
        telescope.find_files({
          prompt_title = 'Sessionizer - Select Directory',
          find_command = find_command,
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              
              if selection then
                local dir = selection[1]
                
                -- Save current session before switching
                vim.cmd('silent! AutoSession save')
                
                -- Close all buffers
                vim.cmd('silent! %bdelete')
                
                -- Change directory
                vim.cmd('cd ' .. vim.fn.fnameescape(dir))
                
                -- Small delay to ensure directory change is complete
                vim.defer_fn(function()
                  -- Get current directory and manually escape it using URL encoding
                  local cwd = vim.fn.getcwd()
                  local clean_cwd = cwd:gsub('\\+$', '')  -- Remove trailing backslash
                  -- Encode special characters: backslash, colon, dot, and space
                  local escaped = clean_cwd:gsub('\\', '%%5C'):gsub(':', '%%3A'):gsub('%.', '%%2E'):gsub(' ', '%%20')
                  
                  local session_root = vim.fn.stdpath('data') .. '/sessions/'
                  local session_file = session_root .. escaped .. '.vim'
                  
                  -- Log to file
                  local log_file = io.open('C:\\Users\\lph15526\\sessionizer-debug.log', 'a')
                  if log_file then
                    log_file:write('=== Sessionizer Debug ===\n')
                    log_file:write('Selected dir: ' .. dir .. '\n')
                    log_file:write('Current dir: ' .. cwd .. '\n')
                    log_file:write('Clean cwd: ' .. clean_cwd .. '\n')
                    log_file:write('Escaped dir: ' .. escaped .. '\n')
                    log_file:write('Session root: ' .. session_root .. '\n')
                    log_file:write('Session file: ' .. session_file .. '\n')
                    log_file:write('Filereadable: ' .. vim.fn.filereadable(session_file) .. '\n')
                    log_file:write('\n')
                    log_file:close()
                  end
                  
                  -- Check if session file exists
                  if vim.fn.filereadable(session_file) == 1 then
                    -- Session exists, restore it
                    vim.cmd('silent! AutoSession restore')
                  else
                    -- No session exists, open oil
                    require('oil').open(dir)
                  end
                end, 100)
              end
            end)
            
            return true
          end,
        })
      end,
      desc = 'Sessionizer - Find and switch to directory',
    },
  },
}
