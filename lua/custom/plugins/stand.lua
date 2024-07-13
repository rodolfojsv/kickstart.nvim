return {
  require('stand').setup {
    minute_interval = 60,
  },

  vim.keymap.set('n', '<leader>stw', '<CMD>StandWhen<CR>', { desc = '[St]and [W]hen' }),
  vim.keymap.set('n', '<leader>std', '<CMD>StandDisable<CR>', { desc = '[St]and [D]isable' }),
  vim.keymap.set('n', '<leader>ste', '<CMD>StandEnable<CR>', { desc = '[St]and [E]nable' }),
  vim.keymap.set('n', '<leader>stn', '<CMD>StandNow<CR>', { desc = '[St]and [N]ow' }),
}
