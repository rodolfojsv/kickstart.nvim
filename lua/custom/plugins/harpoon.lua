return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    -- Setup harpoon with settings that enable persistence
    harpoon:setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      }
    })
    
    -- Helper function to safely get a harpoon list
    -- Uses the selected list from the number manager (harpoonlist.lua)
    local function get_list()
      local list_name = vim.g.selected_list or 'harpoonlist_0'
      return harpoon:list(list_name)
    end
    
    vim.keymap.set('n', '<leader>ha', function()
      get_list():add()
    end, { desc = 'Add file to harpoon' })

    vim.keymap.set('n', '<leader>hm', function()
      harpoon.ui:toggle_quick_menu(get_list())
    end, { desc = 'Show harpoon menu' })

    vim.keymap.set('n', '<C-h>', function()
      get_list():next()
    end, { desc = 'Go to next harpoon file' })

    vim.keymap.set('n', '<C-l>', function()
      get_list():prev()
    end, { desc = 'Go to previous harpoon file' })
  end,
}
