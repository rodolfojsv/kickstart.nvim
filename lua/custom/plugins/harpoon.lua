return {
  'ThePrimeagen/harpoon',

  vim.keymap.set('n', '<leader>ha', ':lua require("harpoon.mark").add_file()<Enter>', { desc = 'Add file to harpoon' }),
  vim.keymap.set('n', '<leader>hm', ':lua require("harpoon.ui").toggle_quick_menu()<Enter>', { desc = 'show file list' }),
  vim.keymap.set('n', '<C-h>', ':lua require("harpoon.ui").nav_next()<Enter>', { desc = 'go to next file' }),
  vim.keymap.set('n', '<C-l>', ':lua require("harpoon.ui").nav_prev()<Enter>', { desc = 'go to previous file' }),
}
