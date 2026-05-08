return {
  require('reminders').setup {
    directory_path = 'C:\\Users\\lph15526\\OneDrive - IGT\\Documents\\reminders',
    briefing = {
      name = 'Rodolfo',
      on_startup = "once_daily"
    },
    jira = {
      enabled = true,
      bin = 'C:\\Users\\lph15526\\AppData\\Local\\jira-cli\\bin\\jira.exe',
      host = 'https://igt-casinosystems.atlassian.net',
      jql = "assignee=currentUser() AND resolution=Unresolved AND project IN (SMIB, CCCB)",
      exclude_statuses = { 'Done', 'Closed', 'DESCOPED' },
    },
  },
  vim.keymap.set('n', '<leader>rme', ':RemindMeEvery ', { desc = '[R]emind [M]e [E]very and type minutes' }),
  vim.keymap.set('n', '<leader>rma', ':RemindMeAt ', { desc = '[R]emind [M]e [A]t and type hour of day (24h)' }),
  vim.keymap.set('n', '<leader>rmi', ':RemindMeIn ', { desc = '[R]emind [M]e [I]n and type minutes' }),
  vim.keymap.set('n', '<leader>rmda', ':RemindMeDailyAt ', { desc = '[R]emind [M]e [D]aily [A]t and type hour of day (24h)' }),
  vim.keymap.set('n', '<leader>rmc', ':ReminderClose<CR>', { desc = '[R]e[m]inder [C]lose' }),
  vim.keymap.set('n', '<leader>rmrz', ':ReminderRemoveAll<CR>', { desc = '[R]e[m]inder [R]emove All' }),
  vim.keymap.set('n', '<leader>rmra', ':ReminderRemoveAt ', { desc = '[R]e[m]inder [R]emove [A]t' }),
  vim.keymap.set('n', '<leader>rmfo', ':ReminderFocusModeOff<CR>', { desc = '[R]e[m]inder [F]ocusMode [O]ff' }),
  vim.keymap.set('n', '<leader>rmfm', ':ReminderFocusModeOn<CR>', { desc = '[R]e[m]inder [F]ocus[M]ode On' }),
  vim.keymap.set('n', '<leader>rmb', ':ReminderBriefing<CR>', { desc = '[R]e[m]inder [B]riefing' }),
}
