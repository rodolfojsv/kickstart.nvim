return {
  'hoob3rt/lualine.nvim',
  dependencies = {
    'folke/tokyonight.nvim',
  },
  config = function()
    --TODO: probably easier to check this while on battery.
    local nvimbattery = {
      function()
        return require('battery').get_status_line()
      end,
      -- color = { fg = colors.violet, bg = colors.bg },
    }
    require('lualine').setup {
      options = {
        theme = 'tokyonight-night',
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          {
            'filename',
            path = 1,
            shortening_target = 70,
          },
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      tabline = {
        lualine_a = {
          {
            'tabs',
            mode = 1,
            tabs_color = {
              active = 'lualine_a_normal',
              inactive = 'lualine_c_inactive',
            },
          },
        },
      },
      extensions = {
        'quickfix',
      },
    }
  end,
}
