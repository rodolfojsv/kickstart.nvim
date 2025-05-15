return {
  'hoob3rt/lualine.nvim',
  dependencies = {
    'folke/tokyonight.nvim',
  },
  config = function()
    -- use emotes for mode names
    local mode_map = {
      n = '(ᴗ_ ᴗ。)',
      nt = '(ᴗ_ ᴗ。)',
      i = '(•̀ - •́ )',
      R = '( •̯́ ₃ •̯̀)',
      v = '(⊙ _ ⊙ )',
      V = '(⊙ _ ⊙ )',
      no = 'Σ(°△°ꪱꪱꪱ)',
      ['\22'] = '(⊙ _ ⊙ )',
      t = '(⌐■_■)',
      ['!'] = 'Σ(°△°ꪱꪱꪱ)',
      c = 'Σ(°△°ꪱꪱꪱ)',
      s = '( •̯́ ₃ •̯̀)',
    }
    require('lualine').setup {
      options = {
        theme = 'tokyonight-night',
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          {
            'mode',
            icons_enabled = true,
            separator = {
              left = '',
              right = '',
              -- right = ""
            },
            fmt = function()
              return mode_map[vim.api.nvim_get_mode().mode] or vim.api.nvim_get_mode().mode
            end,
          },
        },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          {
            'filename',
            path = 1,
            shortening_target = 70,
          },
        },
        lualine_x = { 'encoding', 'filetype' },
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
