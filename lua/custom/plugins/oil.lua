return {
  'stevearc/oil.nvim',
  keys = {
    { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
  },
  event = 'VimEnter',  -- Load early for directory handling
  config = function()
    require('oil').setup {
      skip_confirm_for_simple_edits = true,
      default_file_explorer = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == '..' or name == '.git' or name == '.DS_Store' or name == '.vs' or name == '.vscode' or name:endswith '.pdb' or name:endswith '.old'
        end,
      },
      win_options = {
        wrap = true,
      },
    }
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    vim.keymap.set('n', '<leader>yp', function()
      local dir = require('oil').get_current_dir()
      if dir then
        vim.fn.setreg('+', dir)
      end
    end, { desc = 'Yank oil current directory path' })
    
    -- Open oil on startup only when a directory argument is provided
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        -- Only proceed if arguments were provided (not plain 'nvim')
        if vim.fn.argc() == 0 then
          return  -- Let dashboard show
        end
        
        local buf_name = vim.api.nvim_buf_get_name(0)
        local buf_ft = vim.bo.filetype
        
        -- Open oil if buffer is empty/directory and not a special filetype
        if buf_name == '' and buf_ft ~= 'dashboard' then
          require('oil').open()
        end
      end,
    })
  end,
}
