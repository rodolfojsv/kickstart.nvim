-- Number Manager Plugin
-- Manages a list of auto-incremental numbers with selection capability

local M = {}

-- Configuration
local config = {
  data_file = vim.fn.stdpath('data') .. '/number_manager.txt',
  current_number = 0,
  selected_list = '0',
}

-- Read the data file and parse numbers
local function read_numbers()
  local file = io.open(config.data_file, 'r')
  if not file then
    return {}
  end

  local numbers = {}
  local content = file:read('*all')
  file:close()

  -- Parse lines, looking for number entries with optional aliases
  -- Format: [*]<number>[:<alias>]
  for line in content:gmatch('[^\r\n]+') do
    local is_selected = line:match('^%*')
    local num_part = is_selected and line:sub(2) or line
    local num, alias = num_part:match('(%d+):?(.*)')
    num = tonumber(num)
    
    if num then
      -- If no alias, default to harpoonlist_<number>
      if not alias or alias == '' then
        alias = 'harpoonlist_' .. num
      end
      
      table.insert(numbers, {
        number = num,
        alias = alias,
        selected = is_selected ~= nil,
      })
      if is_selected then
        config.selected_list = 'harpoonlist_' .. num
      end
      -- Track the highest number
      if num > config.current_number then
        config.current_number = num
      end
    end
  end

  return numbers
end

-- Write numbers back to file
local function write_numbers(numbers)
  local file = io.open(config.data_file, 'w')
  if not file then
    return false
  end

  for i, item in ipairs(numbers) do
    local prefix = item.selected and '*' or ''
    file:write(prefix .. item.number .. ':' .. item.alias .. '\n')
    if i < #numbers then
      file:write('\n') -- Empty line between entries
    end
  end

  file:close()
  return true
end

-- Add a new number
local function add_number()
  local numbers = read_numbers()
  
  -- Increment and add new number
  config.current_number = config.current_number + 1
  local new_number = config.current_number

  -- Unselect all previous numbers
  for _, item in ipairs(numbers) do
    item.selected = false
  end

  -- Add new number as selected with default alias
  table.insert(numbers, {
    number = new_number,
    alias = 'harpoonlist_' .. new_number,
    selected = true,
  })

  config.selected_list = 'harpoonlist_' .. new_number

  if write_numbers(numbers) then
    -- Update the global variable
    vim.g.selected_list = config.selected_list
  end
end

-- Set a number as selected
local function select_number(num)
  local numbers = read_numbers()
  local found = false

  -- Update selection
  for _, item in ipairs(numbers) do
    if item.number == num then
      item.selected = true
      found = true
      config.selected_list = 'harpoonlist_' .. num
    else
      item.selected = false
    end
  end

  if found then
    write_numbers(numbers)
    vim.g.selected_list = config.selected_list
  end
end

-- Remove a number
local function remove_number(num)
  local numbers = read_numbers()
  local new_numbers = {}
  local was_selected = false

  for _, item in ipairs(numbers) do
    if item.number ~= num then
      table.insert(new_numbers, item)
    else
      was_selected = item.selected
    end
  end

  -- If we removed the selected item, reset to 0
  if was_selected then
    config.selected_list = '0'
    vim.g.selected_list = '0'
  end

  write_numbers(new_numbers)
end

-- Rename/alias a list
local function rename_list(num, new_alias)
  local numbers = read_numbers()
  local found = false

  for _, item in ipairs(numbers) do
    if item.number == num then
      item.alias = new_alias
      found = true
      break
    end
  end

  if found then
    write_numbers(numbers)
    return true
  end
  return false
end

-- Show the number selector
local function show_selector()
  local numbers = read_numbers()

  if #numbers == 0 then
    return
  end

  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Prepare display lines
  local lines = {}
  local number_map = {} -- Map line number to actual number
  
  for i, item in ipairs(numbers) do
    local prefix = item.selected and '* ' or '  '
    local display = item.alias .. ' (#' .. item.number .. ')'
    local line = prefix .. display .. (item.selected and ' (selected)' or '')
    table.insert(lines, line)
    number_map[i] = item.number
  end

  local total_items = #numbers

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- Calculate window size
  local width = 50
  local height = math.min(#lines + 2, 20)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Harpoon List Manager ',
    title_pos = 'center',
  })

  -- Set window options
  vim.api.nvim_win_set_option(win, 'cursorline', true)

  -- Keymaps for the selector buffer
  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- Close on q or Esc
  vim.keymap.set('n', 'q', close_window, { buffer = buf, nowait = true })
  vim.keymap.set('n', '<Esc>', close_window, { buffer = buf, nowait = true })

  -- Circular navigation with Ctrl+N and Ctrl+P
  vim.keymap.set('n', '<C-n>', function()
    local current_line = vim.api.nvim_win_get_cursor(win)[1]
    local next_line = current_line >= total_items and 1 or current_line + 1
    vim.api.nvim_win_set_cursor(win, { next_line, 0 })
  end, { buffer = buf, nowait = true })

  vim.keymap.set('n', '<C-p>', function()
    local current_line = vim.api.nvim_win_get_cursor(win)[1]
    local prev_line = current_line <= 1 and total_items or current_line - 1
    vim.api.nvim_win_set_cursor(win, { prev_line, 0 })
  end, { buffer = buf, nowait = true })

  -- Select on Enter
  vim.keymap.set('n', '<CR>', function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local selected_num = number_map[line]
    if selected_num then
      close_window()
      select_number(selected_num)
    end
  end, { buffer = buf, nowait = true })

  -- Delete on dd
  vim.keymap.set('n', 'dd', function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local num_to_delete = number_map[line]
    if num_to_delete then
      close_window()
      remove_number(num_to_delete)
      -- Reopen to show updated list
      vim.defer_fn(show_selector, 50)
    end
  end, { buffer = buf, nowait = true })

  -- Rename on r
  vim.keymap.set('n', 'r', function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local num_to_rename = number_map[line]
    if num_to_rename then
      close_window()
      vim.ui.input({ prompt = 'New alias: ' }, function(input)
        if input and input ~= '' then
          rename_list(num_to_rename, input)
          -- Reopen to show updated list
          vim.defer_fn(show_selector, 50)
        end
      end)
    end
  end, { buffer = buf, nowait = true })
end

-- Load selected number on startup
local function load_on_startup()
  local numbers = read_numbers()
  
  for _, item in ipairs(numbers) do
    if item.selected then
      config.selected_list = 'harpoonlist_' .. item.number
      vim.g.selected_list = config.selected_list
      return
    end
  end

  -- No selected list found, default to 0
  config.selected_list = 'harpoonlist_0'
  vim.g.selected_list = config.selected_list
end

-- Setup function
M.setup = function(opts)
  opts = opts or {}
  
  -- Allow custom data file location
  if opts.data_file then
    config.data_file = opts.data_file
  end

  -- Load selected list on startup
  load_on_startup()

  -- Create commands
  vim.api.nvim_create_user_command('ListAdd', add_number, {
    desc = 'Add a new list',
  })

  vim.api.nvim_create_user_command('ListSelect', show_selector, {
    desc = 'Show list selector',
  })

  vim.api.nvim_create_user_command('ListRename', function(opts)
    local num = tonumber(opts.args)
    if not num then
      print('Usage: ListRename <number>')
      return
    end
    vim.ui.input({ prompt = 'New alias for list ' .. num .. ': ' }, function(input)
      if input and input ~= '' then
        if rename_list(num, input) then
          print('List ' .. num .. ' renamed to: ' .. input)
        else
          print('List ' .. num .. ' not found')
        end
      end
    end)
  end, {
    nargs = 1,
    desc = 'Rename a list alias',
  })

  vim.api.nvim_create_user_command('ListShow', function()
    print('Selected list: ' .. (vim.g.selected_list or '0'))
  end, {
    desc = 'Show currently selected list',
  })

  -- Set up keymaps if provided
  if opts.keymaps ~= false then
    vim.keymap.set('n', '<leader>hla', add_number, { desc = '[H]arpoon [L]ist [A]dd' })
    vim.keymap.set('n', '<leader>hls', show_selector, { desc = '[H]arpoon [L]ist [S]elect' })
    vim.keymap.set('n', '<leader>hlw', function()
      print('Selected list: ' .. (vim.g.selected_list or '0'))
    end, { desc = '[H]arpoon [L]ist [W]hat\'s selected' })
  end
end

-- Return plugin spec for lazy.nvim
return {
  name = 'number-manager',
  dir = vim.fn.stdpath('config') .. '/lua/custom/plugins',
  config = function()
    M.setup()
  end,
}
