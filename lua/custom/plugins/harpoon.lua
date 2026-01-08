return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
  local harpoon = require 'harpoon'

  -- Setup harpoon - all lists are global
  harpoon:setup()
  
  vim.keymap.set('n', '<leader>ha', function()
    harpoon:list():add()
  end, { desc = 'Add file to harpoon' })

  vim.keymap.set('n', '<leader>hm', function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end, { desc = 'Show harpoon menu' })

  vim.keymap.set('n', '<C-h>', function()
    harpoon:list():next()
  end, { desc = 'Go to next harpoon file' })

  vim.keymap.set('n', '<C-l>', function()
    harpoon:list():prev()
  end, { desc = 'Go to previous harpoon file' })
  end,
}
