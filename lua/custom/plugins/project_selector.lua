local workspace = vim.env.NEOSMIB_WORKSPACE or 'C:\\Dev\\NeoSMIB'
local repository = workspace .. '\\SMIB'

local function exists(path)
  return vim.fn.filereadable(path) == 1
end

local function context()
  if exists(repository .. '\\CMakeLists.txt') then
    return { layout = 'Modern', linux = true }
  end
  if exists(repository .. '\\EGS\\ABS\\CMakeLists.txt') then
    return { layout = 'Legacy', linux = false }
  end
  vim.notify('Unsupported SMIB layout under ' .. repository, vim.log.levels.ERROR)
end

local function projects()
  local pattern = repository .. '\\EGS\\ABS\\source\\Software\\MBE2\\CMakeFiles\\be2_*\\CMakeLists.txt'
  local names = {}
  for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
    local name = vim.fn.fnamemodify(vim.fn.fnamemodify(path, ':h'), ':t')
    if not name:match '_UnitTest$' then
      table.insert(names, name)
    end
  end
  table.sort(names)
  return names
end

local function terminal(script, arguments)
  local command = {
    'powershell.exe',
    '-NoExit',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    workspace .. '\\' .. script,
  }
  vim.list_extend(command, arguments or {})
  vim.cmd 'botright new'
  vim.fn.termopen(command, { cwd = workspace })
  vim.cmd 'startinsert'
end

local function select_project(prompt, include_all, include_linux, callback)
  local ctx = context()
  if not ctx then
    return
  end

  local items = {}
  if include_all then
    table.insert(items, { label = 'All unit tests (Windows)', project = 'All', platform = 'Windows' })
  end
  for _, project in ipairs(projects()) do
    table.insert(items, { label = project .. ' (Windows)', project = project, platform = 'Windows' })
    if include_linux and ctx.linux then
      table.insert(items, { label = project .. ' (Linux)', project = project, platform = 'Linux' })
    end
  end

  vim.ui.select(items, {
    prompt = prompt,
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

local function setup()
  vim.keymap.set('n', '<leader>cg', function()
    terminal('setup.ps1', { '-BuildType', 'Debug' })
  end, { desc = '[C]Make [G]enerate compile commands' })

  vim.keymap.set('n', '<leader>cp', function()
    select_project('Build SMIB project:', false, true, function(choice)
      terminal('run-project.ps1', { '-ProjectName', choice.project, '-Platform', choice.platform, '-BuildType', 'Debug' })
    end)
  end, { desc = '[C]Make [P]roject' })

  vim.keymap.set('n', '<leader>ct', function()
    select_project('Run SMIB unit tests:', true, false, function(choice)
      terminal('run-unit-tests.ps1', { '-ProjectName', choice.project, '-Platform', choice.platform })
    end)
  end, { desc = '[C]Make unit [T]ests' })

  vim.keymap.set('n', '<leader>cm', function()
    select_project('Build SMIB MOT:', false, false, function(choice)
      terminal('build-mot.ps1', { '-ProjectName', choice.project, '-Platform', choice.platform })
    end)
  end, { desc = '[C]Make [M]OT package' })
end

return {
  name = 'smib-workflow',
  dir = vim.fn.stdpath 'config' .. '/lua/custom/plugins',
  lazy = false,
  init = setup,
}
