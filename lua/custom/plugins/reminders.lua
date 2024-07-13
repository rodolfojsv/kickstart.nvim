return {
  require('reminders').setup { directory_path = '/Users/rodolfojosesilvavazquez/Development/reminders' },
  vim.keymap.set('n', '<leader>rme', ':RemindMeEvery ', { desc = '[R]emind [M]e [E]very and type minutes' }),
  vim.keymap.set('n', '<leader>rma', ':RemindMeAt ', { desc = '[R]emind [M]e [A]t and type hour of day (24h)' }),
  vim.keymap.set('n', '<leader>rmda', ':RemindMeAt ', { desc = '[R]emind [M]e [D]aily [A]t and type hour of day (24h)' }),
  vim.keymap.set('n', '<leader>rmc', ':ReminderClose<CR>', { desc = '[R]e[m]inder [C]lose' }),
}
