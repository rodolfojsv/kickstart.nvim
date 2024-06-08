return {
  vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Center after C-D' }),
  vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Center after C-U' }),
  vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Center after next (n)' }),
  vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Center after next (N)' }),
  vim.keymap.set('n', '<leader>nt', ':vsplit<Enter>', { desc = 'Vertical Split' }),
}
