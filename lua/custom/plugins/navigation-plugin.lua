return {
  -- For local development
  dir = vim.fn.expand('~/Dev/navigation'),
  -- For GitHub version, comment out the line above and uncomment below:
  -- 'rodolfojsv/navigation.nvim',
  config = function()
    require('navigation').setup({
      nav_file = vim.fn.expand('~/Dev/navigation.nvim'),
      keymap = '<leader>cn',
      keymap_desc = '[C]ustom [N]avigation - Open file from navigation list',
      keymap_add = '<leader>ca',  -- Change to your preferred keymap
      keymap_add_desc = '[C]ustom [A]dd to navigation',
      auto_cd = true,
      show_notifications = false,  -- Set to true if you want notifications
    })
  end,
}
