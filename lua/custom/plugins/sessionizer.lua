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
                -- Change directory
                vim.cmd('cd ' .. vim.fn.fnameescape(dir))
                print('Changed directory to: ' .. dir)
                
                -- Open oil in the new directory
                vim.defer_fn(function()
                  require('oil').open(dir)
                end, 50)
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
