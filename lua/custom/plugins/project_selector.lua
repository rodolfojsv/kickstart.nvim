local workspace = vim.env.NEOSMIB_WORKSPACE or 'C:\\Dev\\NeoSMIB'
local repository = workspace .. '\\SMIB'
local usage_file = vim.fn.stdpath 'state' .. '\\smib-project-usage.json'
local usage = {}

if vim.fn.filereadable(usage_file) == 1 then
  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(usage_file), '\n'))
  if ok and type(decoded) == 'table' then
    usage = decoded
  else
    vim.notify('Ignoring invalid SMIB project usage file: ' .. usage_file, vim.log.levels.WARN)
  end
end

local function exists(path)
  return vim.fn.filereadable(path) == 1
end

local function context()
  if exists(repository .. '\\CMakeLists.txt') then
    return {
      layout = 'Modern',
      linux = true,
      include_projects = repository .. '\\IncludeProjects.cmake',
    }
  end
  if exists(repository .. '\\EGS\\ABS\\CMakeLists.txt') then
    return {
      layout = 'Legacy',
      linux = false,
      include_projects = repository .. '\\EGS\\ABS\\IncludeProjects.cmake',
    }
  end
  vim.notify('Unsupported SMIB layout under ' .. repository, vim.log.levels.ERROR)
end

local function current_project(ctx)
  if not exists(ctx.include_projects) then
    return nil
  end
  for _, line in ipairs(vim.fn.readfile(ctx.include_projects)) do
    local project = vim.trim(line)
    if project ~= '' then
      return project
    end
  end
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

local function usage_key(item)
  return item.project .. ':' .. item.platform
end

local function record_usage(selector, item)
  usage[selector] = usage[selector] or {}
  local key = usage_key(item)
  usage[selector][key] = (usage[selector][key] or 0) + 1
  vim.fn.mkdir(vim.fn.fnamemodify(usage_file, ':h'), 'p')
  if vim.fn.writefile({ vim.json.encode(usage) }, usage_file) ~= 0 then
    vim.notify('Failed to save SMIB project usage: ' .. usage_file, vim.log.levels.ERROR)
  end
end

local function terminal(script, arguments, options)
  options = options or {}
  local command = {
    'powershell.exe',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    workspace .. '\\' .. script,
  }
  if options.keep_open ~= false then
    table.insert(command, 2, '-NoExit')
  end
  vim.list_extend(command, arguments or {})
  vim.cmd 'botright new'
  vim.fn.termopen(command, {
    cwd = workspace,
    on_exit = function(_, code)
      if options.on_exit then
        vim.schedule(function()
          options.on_exit(code)
        end)
      end
    end,
  })
  vim.cmd 'startinsert'
end

local function select_project(prompt, include_all, include_linux, callback, options)
  options = options or {}
  local ctx = context()
  if not ctx then
    return
  end
  local current = options.show_current and current_project(ctx) or nil

  local items = {}
  if include_all then
    table.insert(items, { label = 'All unit tests (Windows)', project = 'All', platform = 'Windows' })
  end
  for _, project in ipairs(projects()) do
    local status = project == current and ', current' or ''
    table.insert(items, { label = project .. ' (Windows' .. status .. ')', project = project, platform = 'Windows' })
    if include_linux and ctx.linux then
      table.insert(items, { label = project .. ' (Linux)', project = project, platform = 'Linux' })
    end
  end
  if options.usage then
    local counts = usage[options.usage] or {}
    table.sort(items, function(left, right)
      local left_count = counts[usage_key(left)] or 0
      local right_count = counts[usage_key(right)] or 0
      if left_count ~= right_count then
        return left_count > right_count
      end
      return left.label < right.label
    end)
  end

  vim.ui.select(items, {
    prompt = current and (prompt .. ' Current: ' .. current) or prompt,
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      if options.usage then
        record_usage(options.usage, choice)
      end
      callback(choice)
    end
  end)
end

local function setup()
  vim.keymap.set('n', '<leader>cg', function()
    select_project('Generate compile commands for:', false, false, function(choice)
      terminal('setup.ps1', { '-BuildType', 'Debug', '-Projects', choice.project }, {
        keep_open = false,
        on_exit = function(code)
          if code ~= 0 then
            vim.notify('CMake generation failed', vim.log.levels.ERROR)
            return
          end
          vim.lsp.enable('clangd', false)
          vim.defer_fn(function()
            vim.lsp.enable('clangd', true)
          end, 200)
          vim.notify('clangd target: ' .. choice.project, vim.log.levels.INFO)
        end,
      })
    end, { show_current = true, usage = 'cg' })
  end, { desc = '[C]Make [G]enerate compile commands' })

  vim.keymap.set('n', '<leader>cp', function()
    select_project('Build SMIB project:', false, true, function(choice)
      terminal('run-project.ps1', { '-ProjectName', choice.project, '-Platform', choice.platform, '-BuildType', 'Debug' })
    end)
  end, { desc = '[C]Make [P]roject' })

  vim.keymap.set('n', '<leader>ct', function()
    select_project('Run SMIB unit tests:', true, false, function(choice)
      terminal('run-unit-tests.ps1', { '-ProjectName', choice.project, '-Platform', choice.platform })
    end, { usage = 'ct' })
  end, { desc = '[C]Make unit [T]ests' })

  vim.keymap.set('n', '<leader>cm', function()
    select_project('Build SMIB MOT:', false, false, function(choice)
      terminal('build-mot.ps1', { '-ProjectName', choice.project, '-Platform', choice.platform })
    end, { usage = 'cm' })
  end, { desc = '[C]Make [M]OT package' })
end

return {
  name = 'smib-workflow',
  dir = vim.fn.stdpath 'config' .. '/lua/custom/plugins',
  lazy = false,
  init = setup,
}
