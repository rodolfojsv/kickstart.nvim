return {
  'rodolfojsv/log-filter.nvim',
  -- For local development, uncomment the line below and comment out the line above
  -- dir = 'C:/Dev/logfilter.nvim',
  config = function()
  require('log-filter').setup {
    history_file = 'C:/temp/nvim_log_filter_history.txt',
    max_history = 20,
    load_entry_key = '<C-e>',
    decompress_commands = {
      ['.zip'] = '"C:\\Program Files\\7-Zip\\7z.exe" x -so "%s"',
      ['.gz'] = '"C:\\Program Files\\7-Zip\\7z.exe" x -so "%s"', -- Optional: 7z can handle .gz too
      ['.7z'] = '"C:\\Program Files\\7-Zip\\7z.exe" x -so "%s"', -- Optional: for .7z files
    },
  }
  end,
}
