return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
  local harpoon = require 'harpoon'

  -- Setup harpoon with global settings
  harpoon:setup({
    settings = {
      save_on_toggle = true,
      sync_on_ui_close = true,
      key = function()
        -- Return a constant key to make all lists global across directories
        return "global"
      end,
    },
  })
  
  vim.keymap.set('n', '<leader>ha', function()
    local current_file = vim.api.nvim_buf_get_name(0)
    local cwd = vim.fn.getcwd()
    
    -- If we're in C:\Dev\NeoSMIB and the file path is relative or within that directory
    if cwd:match('^C:\\Dev\\NeoSMIB') then
      -- Convert to absolute path if it's relative
      if not current_file:match('^%a:') then  -- Not an absolute path (no drive letter)
        current_file = cwd .. '\\' .. current_file
      end
      -- Normalize the path
      current_file = vim.fn.fnamemodify(current_file, ':p')
    end
    
    harpoon:list(vim.g.selected_list):add({ value = current_file })
  end, { desc = 'Add file to harpoon' })

  vim.keymap.set('n', '<leader>hm', function()
    harpoon.ui:toggle_quick_menu(harpoon:list(vim.g.selected_list))
  end, { desc = 'Show harpoon menu' })

  vim.keymap.set('n', '<C-h>', function()
    harpoon:list(vim.g.selected_list):next()
  end, { desc = 'Go to next harpoon file' })

  vim.keymap.set('n', '<C-l>', function()
    harpoon:list(vim.g.selected_list):prev()
  end, { desc = 'Go to previous harpoon file' })
  end,
}
