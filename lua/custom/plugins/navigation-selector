return {
  vim.keymap.set('n', '<leader>cn', function()
    local nav_file = 'C:\\Dev\\navigation.nvim'
    
    -- Check if the navigation file exists
    local file = io.open(nav_file, 'r')
    if not file then
      vim.notify('Navigation file not found: ' .. nav_file, vim.log.levels.ERROR)
      return
    end
    
    -- Read all lines from the file
    local files = {}
    for line in file:lines() do
      -- Trim whitespace and skip empty lines
      local trimmed = line:match('^%s*(.-)%s*$')
      if trimmed ~= '' then
        table.insert(files, trimmed)
      end
    end
    file:close()
    
    if #files == 0 then
      vim.notify('No files found in navigation file', vim.log.levels.WARN)
      return
    end
    
    -- Show selector
    vim.ui.select(files, {
      prompt = 'Select file or directory:',
      format_item = function(item)
        -- Show just the filename/dirname if it's a full path, otherwise show as-is
        local name = item:match('([^/\\]+)$') or item
        -- Check if it's a directory
        local is_dir = vim.fn.isdirectory(item) == 1
        local prefix = is_dir and '[DIR] ' or ''
        return prefix .. name .. ' (' .. item .. ')'
      end,
    }, function(choice)
      if choice then
        -- Check if the choice is a directory
        if vim.fn.isdirectory(choice) == 1 then
          -- Open directory in netrw
          vim.cmd('edit ' .. vim.fn.fnameescape(choice))
        else
          -- Open the selected file
          vim.cmd('edit ' .. vim.fn.fnameescape(choice))
        end
      end
    end)
  end, { desc = '[C]ustom [N]avigation - Open file from navigation list' })
}
