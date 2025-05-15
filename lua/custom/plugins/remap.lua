return {
  vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Center after C-U' }),
  vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Center after C-D' }),
  vim.keymap.set('i', '<C-c>', '<Esc>'),
  vim.keymap.set('n', '<leader>nt', ':vsplit<Enter>', { desc = 'Vertical Split' }),
  vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Center after next (N)' }),
  vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Center after next (n)' }),
  vim.keymap.set('n', '<C-S-k>', ':m .-2<CR>=='), -- move line down(n)
  vim.keymap.set('v', '<C-S-j>', ":m '>+1<CR>gv=gv"), -- move line up(v)
  vim.keymap.set('n', '<C-S-j>', ':m .+1<CR>=='), -- move line up(n)
  vim.keymap.set('v', '<C-S-k>', ":m '<-2<CR>gv=gv"), -- move line down(v)
  vim.keymap.set('n', '<leader><C-n>', '<cmd>cnext<CR>zz', { desc = 'Next item on quickfix list' }),
  vim.keymap.set('n', '<leader><C-p>', '<cmd>cprev<CR>zz', { desc = 'Previous item on quickfix list' }),
  vim.keymap.set('n', '<leader>prt', ":lua require('precognition').toggle()<CR>", { desc = '[Pr]ecognition [t]oggle' }),
  vim.keymap.set('x', '<leader>p', [["_dP]]),
  vim.keymap.set('n', '<C-S-a>', '<C-a>'),
  vim.keymap.set('n', '<C-S-x>', '<C-x>'),
  vim.keymap.set('n', '<leader><C-s>', '<cmd>:so ~/.config/nvim/lua/snippets/basiccssnipppets.lua<CR>'),
  vim.keymap.set('i', '<F18>', function()
    require('luasnip').jump(1)
  end),
  vim.keymap.set('i', '<F19>', function()
    require('luasnip').jump(-1)
  end),
  vim.keymap.set('i', '<F16>', function()
    if require('luasnip').choice_active() then
      require('luasnip').change_choice(1)
    end
  end),
  vim.keymap.set('i', '<F17>', function()
    if require('luasnip').choice_active() then
      require('luasnip').change_choice(-1)
    end
  end),
  vim.keymap.set('s', '<F18>', function()
    require('luasnip').jump(1)
  end),
  vim.keymap.set('s', '<F19>', function()
    require('luasnip').jump(-1)
  end),
  vim.keymap.set('s', '<F16>', function()
    if require('luasnip').choice_active() then
      require('luasnip').change_choice(1)
    end
  end),
  vim.keymap.set('s', '<F17>', function()
    if require('luasnip').choice_active() then
      require('luasnip').change_choice(-1)
    end
  end),
}
