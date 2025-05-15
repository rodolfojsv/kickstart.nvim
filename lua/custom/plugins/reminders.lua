return {
  require('reminders').setup { directory_path = '/Users/rodolfojosesilvavazquez/Development/reminders' },
  vim.keymap.set('n', '<leader>rme', ':RemindMeEvery ', { desc = '[R]emind [M]e [E]very and type minutes' }),
  vim.keymap.set('n', '<leader>rma', ':RemindMeAt ', { desc = '[R]emind [M]e [A]t and type hour of day (24h)' }),
  vim.keymap.set('n', '<leader>rmi', ':RemindMeIn ', { desc = '[R]emind [M]e [I]n and type minutes' }),
  vim.keymap.set('n', '<leader>rmda', ':RemindMeDailyAt ', { desc = '[R]emind [M]e [D]aily [A]t and type hour of day (24h)' }),
  vim.keymap.set('n', '<leader>rmc', ':ReminderClose<CR>', { desc = '[R]e[m]inder [C]lose' }),
  vim.keymap.set('n', '<leader>rmrz', ':ReminderRemoveAll<CR>', { desc = '[R]e[m]inder [R]emove All' }),
  vim.keymap.set('n', '<leader>rmra', ':ReminderRemoveAt ', { desc = '[R]e[m]inder [R]emove [A]t' }),
  vim.keymap.set('n', '<leader>rmfo', ':ReminderFocusModeOff<CR>', { desc = '[R]e[m]inder [F]ocusMode [O]ff' }),
  vim.keymap.set('n', '<leader>rmfm', ':ReminderFocusModeOn<CR>', { desc = '[R]e[m]inder [F]ocus[M]ode On' }),
}
