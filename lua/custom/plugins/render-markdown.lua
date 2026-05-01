return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  ft = { 'markdown', 'Avante' },
  opts = {
    heading = {
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    },
    code = {
      sign = false,
      width = 'block',
      right_pad = 1,
    },
    bullet = {
      right_pad = 1,
    },
  },
}
