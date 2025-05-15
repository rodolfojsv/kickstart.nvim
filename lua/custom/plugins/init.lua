-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
vim.opt.conceallevel = 1
return {
  'rcarriga/nvim-notify',
  'tpope/vim-eunuch',
  'tpope/vim-repeat',
  'tpope/vim-surround',
  'tpope/vim-unimpaired',
  'tris203/precognition.nvim',
  'justinhj/battery.nvim',
  'nvim-treesitter/nvim-treesitter-context',
  { 'rodolfojsv/reminders.nvim', branch = 'main' },
  { 'kyazdani42/nvim-web-devicons', lazy = true },
  { 'aymericbeaumet/vim-symlink', dependencies = { 'moll/vim-bbye' } },
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },

  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },
}
