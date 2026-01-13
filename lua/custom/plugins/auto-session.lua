return {
  'rmagatti/auto-session',
  lazy = false,
  config = function()
    require('auto-session').setup({
      log_level = 'error',
      auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
      auto_session_use_git_branch = false,
      
      -- Disable auto-restore since we're doing it manually in sessionizer
      auto_session_enabled = false,
      auto_save_enabled = false,
      auto_restore_enabled = false,
      
      -- Suppress session notifications
      suppress_dirs = { '~/', '~/Downloads', '/' },
      silent = true,
      silent_restore = true,
      -- Use directory name as session name
      auto_session_root_dir = vim.fn.stdpath('data') .. '/sessions/',
      
      -- Session lens integration for telescope
      session_lens = {
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
      },
    })
  end,
}
