return {
  -- Project selector for IncludeProjects.cmake
  vim.keymap.set('n', '<leader>cp', function()
    -- Path to the IncludeProjects.cmake file
    local projects_file = vim.fn.getcwd() .. '/SMIB/EGS/ABS/IncludeProjects.cmake'

    -- Check if file exists
    if vim.fn.filereadable(projects_file) == 0 then
      vim.notify('IncludeProjects.cmake not found at: ' .. projects_file, vim.log.levels.ERROR)
      return
    end

    -- Read the file contents
    local file = io.open(projects_file, 'r')
    if not file then
      vim.notify('Could not open IncludeProjects.cmake', vim.log.levels.ERROR)
      return
    end

    local base_projects = {}
    for line in file:lines() do
      -- Trim whitespace and add non-empty lines
      local trimmed = line:match '^%s*(.-)%s*$'
      if trimmed ~= '' then
        table.insert(base_projects, trimmed)
      end
    end
    file:close()

    if #base_projects == 0 then
      vim.notify('No projects found in IncludeProjects.cmake', vim.log.levels.WARN)
      return
    end

    -- Duplicate each entry: add original and then add with _UnitTest suffix
    local projects = {}
    for _, project in ipairs(base_projects) do
      table.insert(projects, project .. '_UnitTest')
    end
    table.insert(projects, 'All')

    -- Use vim.ui.select to show the selector
    vim.ui.select(projects, {
      prompt = 'Select a project:',
      format_item = function(item)
        return item
      end,
    }, function(choice)
      if not choice then
        return -- User cancelled
      end

      -- Path to your PowerShell script
      local script_path = vim.fn.getcwd() .. '/run-project.ps1'

      -- Determine boolean parameter: true if "All", false otherwise
      local bool_param = (choice == 'All') and '$true' or '$false'

      -- Build the command to launch a new terminal window
      -- Using 'start' to open a new window with PowerShell
      local cmd = string.format("start powershell.exe -NoExit -ExecutionPolicy Bypass -Command \"& '%s' '%s' %s\"", script_path, choice, bool_param)

      vim.notify('Running: ' .. choice, vim.log.levels.INFO)

      -- Execute the command to open new terminal
      vim.fn.jobstart(cmd, {
        detach = true,
      })
    end)
  end, { desc = '[C]Make [P]roject Selector' }),
}
