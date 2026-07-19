return {
  'rodolfojsv/navigation.nvim',
  -- dir = 'C:/Dev/navigation', -- Local development
  config = function()
    require('navigation').setup({
      nav_file = 'C:\\Dev\\navigation.nvim',
      keymap = '<leader>cn',
      keymap_desc = '[C]ustom [N]avigation - Open file from navigation list',
      keymap_add = '<leader>ca',  -- Change to your preferred keymap
      keymap_add_desc = '[C]ustom [A]dd to navigation',
      auto_cd = true,
      show_notifications = false,  -- Set to true if you want notifications
    })
  end,
}
