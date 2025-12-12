return {
  'nvimdev/dashboard-nvim',
  lazy = false,
  priority = 1000,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    {
      'rubiin/fortune.nvim',
      config = function()
        require('fortune').setup {
          display_format = 'mixed',
        }
      end,
    },
  },
  config = function()
    require('dashboard').setup {
      theme = 'hyper',
      config = {
        week_header = {
          enable = true,
          append = {
            ' ',
            'Personal Development Environment',
          },
        },
        shortcut = {
          {
            icon = '󰉋 ',
            desc = 'Files',
            group = 'RainbowdelimiterBlue',
            key = 'F',
            action = function()
              require('oil').open_float('.')
            end,
          },
        },
        project = { enable = false },
        mru = {
          limit = 8,
          cwd_only = true,
          label = 'Recent Files',
        },
        footer = function()
          return require('fortune').get_fortune()
        end,
      },
    }
  end,
}
