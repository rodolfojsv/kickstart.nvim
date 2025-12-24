-- Configure netrw to handle zip files with 7zip
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Intercept opening zip files to extract them automatically
vim.api.nvim_create_autocmd('BufReadCmd', {
  pattern = { '*.zip', '*.7z', '*.rar' },
  callback = function(args)
    local filepath = vim.fn.expand('<afile>:p')
    local dir = vim.fn.fnamemodify(filepath, ':h')
    local filename = vim.fn.fnamemodify(filepath, ':t')
    local txt_filename = filename:gsub('%.zip$', '.txt'):gsub('%.7z$', '.txt'):gsub('%.rar$', '.txt')
    local txt_filepath = dir .. '\\' .. txt_filename
    
    -- Check if already extracted
    if vim.fn.filereadable(txt_filepath) == 1 then
      vim.cmd('edit! ' .. vim.fn.fnameescape(txt_filepath))
      return
    end
    
    -- Extract using 7zip (e command extracts without paths)
    local cmd = string.format('powershell -NoProfile -Command "& \\"C:\\Program Files\\7-Zip\\7z.exe\\" e \\"%s\\" -o\\"%s\\" -y 2>&1 | Out-Null"', filepath, dir)
    
    vim.notify('Extracting ' .. filename .. '...', vim.log.levels.INFO)
    vim.fn.system(cmd)
    
    if vim.v.shell_error == 0 and vim.fn.filereadable(txt_filepath) == 1 then
      vim.notify('✓ Extracted successfully', vim.log.levels.INFO)
      vim.cmd('edit! ' .. vim.fn.fnameescape(txt_filepath))
    else
      vim.notify('✗ Extraction failed or file not found: ' .. txt_filename, vim.log.levels.ERROR)
      -- Set buffer as empty and loaded to avoid further netrw complaints
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { '-- Extraction failed --', '', 'File: ' .. filename, 'Expected: ' .. txt_filename })
      vim.bo.buftype = 'nofile'
      vim.bo.modified = false
    end
  end,
})

return {}
