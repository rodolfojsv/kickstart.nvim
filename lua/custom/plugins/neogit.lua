return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "sindrets/diffview.nvim",        -- optional - Diff integration

    -- Only one of these is needed.
    "nvim-telescope/telescope.nvim", -- optional
    "ibhagwan/fzf-lua",              -- optional
    "nvim-mini/mini.pick",           -- optional
    "folke/snacks.nvim",             -- optional
  },
  cmd = "Neogit",
  keys = {
    {
      '<leader>gg',
      function()
        -- Check if we're in NeoSMIB and if SMIB/.git exists
        local cwd = vim.fn.getcwd()
        local git_dir = cwd .. '\\SMIB\\.git'
        
        if vim.fn.isdirectory(git_dir) == 1 then
          -- Open neogit for the SMIB subdirectory
          require('neogit').open({ cwd = cwd .. '\\SMIB' })
        else
          -- Open neogit for current directory
          require('neogit').open()
        end
      end,
      desc = 'Open Neogit',
    },
    {
      '<leader>gc',
      function()
        local cwd = vim.fn.getcwd()
        local git_dir = cwd .. '\\SMIB\\.git'
        
        if vim.fn.isdirectory(git_dir) == 1 then
          require('neogit').open({ 'commit', cwd = cwd .. '\\SMIB' })
        else
          require('neogit').open({ 'commit' })
        end
      end,
      desc = 'Neogit Commit',
    },
  }
}