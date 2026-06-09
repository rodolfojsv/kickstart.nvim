return {
  --'rodolfojsv/log-filter.nvim',
  -- For local development, uncomment the line below and comment out the line above
  dir = vim.fn.expand('~/Dev/logfilter.nvim'),
  config = function()
  require('log-filter').setup {
    history_file = '/tmp/nvim_log_filter_history.txt',
    max_history = 20,
    load_entry_key = '<C-e>',
    decompress_commands = {
      ['.zip'] = '7z e -so "%s"',  -- Use 'e' command instead of 'x'
    },
  }
  end,
}
