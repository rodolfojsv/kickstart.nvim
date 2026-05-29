-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
vim.opt.conceallevel = 1
return {
  'rcarriga/nvim-notify',
  'tpope/vim-eunuch',
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
  'nvim-treesitter/nvim-treesitter-context',
  { 'rodolfojsv/reminders.nvim', branch = 'main' },
  { 'aymericbeaumet/vim-symlink', dependencies = { 'moll/vim-bbye' } },
  {
    -- Maintained fork of norcalli/nvim-colorizer.lua (original is abandoned and
    -- uses APIs removed in Neovim 0.12, which caused deprecation warnings).
    'catgoose/nvim-colorizer.lua',
    event = 'VeryLazy',
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
