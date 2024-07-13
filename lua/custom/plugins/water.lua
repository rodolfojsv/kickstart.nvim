return {

  require('water').setup(),

  vim.keymap.set('n', '<leader>wae', '<CMD>WaterEnable<CR>', { desc = '[Wa]ter [E]nable' }),
  vim.keymap.set('n', '<leader>wad', '<CMD>WaterDisable<CR>', { desc = '[Wa]ter [D]isable' }),
  vim.keymap.set('n', '<leader>wau', '<CMD>WaterUnderstood<CR>', { desc = '[Wa]ter [U]nderstood' }),
}
