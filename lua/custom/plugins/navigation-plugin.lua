return {
  -- For local development
  --dir = 'C:/Dev/navigation',
  -- For GitHub version, comment out the line above and uncomment below:
  'rodolfojsv/navigation.nvim',
  config = function()
    require('navigation').setup({
      nav_file = 'C:\\Dev\\navigation.nvim',
      keymap = '<leader>cn',
      keymap_desc = '[C]ustom [N]avigation - Open file from navigation list',
      auto_cd = true,
      show_notifications = false,  -- Set to true if you want notifications
    })
  end,
}
