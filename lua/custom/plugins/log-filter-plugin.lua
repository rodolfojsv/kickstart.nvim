return {
  'rodolfojsv/log-filter.nvim',
  -- dir = 'C:/Dev/logfilter.nvim', -- Local development
  config = function()
  require('log-filter').setup {
    history_file = 'C:/temp/nvim_log_filter_history.txt',
    max_history = 20,
    load_entry_key = '<C-e>',
    decompress_commands = {
      ['.zip'] = '7z e -so "%s"',  -- Use 'e' command instead of 'x'
    },
  }
  end,
}
