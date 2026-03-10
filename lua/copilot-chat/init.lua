-- copilot-chat: Neovim chat plugin using GitHub Copilot's API
-- Routes requests through your Copilot subscription so you can
-- use premium models (Claude Opus 4.6, etc.) without separate API keys.

local M = {}

-- Default configuration -------------------------------------------------------
M.config = {
  model = 'claude-opus-4.6',
  available_models = {
    'claude-opus-4.6',
    'claude-sonnet-4',
    'gpt-4o',
    'o3-mini',
  },
  system_prompt = 'You are a helpful AI programming assistant powered by GitHub Copilot. '
    .. 'You assist with coding tasks including writing, debugging, explaining, and reviewing code. '
    .. 'Provide clear, concise answers with code examples when appropriate.',
  chat_width = 80,
  input_height = 5,
}

-- Internal state --------------------------------------------------------------
local state = {
  chat_buf = nil,
  input_buf = nil,
  chat_win = nil,
  input_win = nil,
  messages = {},
  session_token = nil,
  token_expires_at = 0,
  current_job = nil,
  streaming = false,
}

-- ═══════════════════════════════════════════════════════════════════════
-- Authentication
-- ═══════════════════════════════════════════════════════════════════════

--- Locate the Copilot OAuth token that copilot.lua / gh-copilot writes.
local function get_oauth_token()
  local candidates = {}

  -- Windows paths
  if vim.fn.has('win32') == 1 then
    local la = vim.fn.expand('$LOCALAPPDATA')
    table.insert(candidates, la .. '/github-copilot/apps.json')
    table.insert(candidates, la .. '/github-copilot/hosts.json')
  end

  -- XDG / Unix paths
  local xdg = vim.env.XDG_CONFIG_HOME or (vim.fn.expand('~') .. '/.config')
  table.insert(candidates, xdg .. '/github-copilot/apps.json')
  table.insert(candidates, xdg .. '/github-copilot/hosts.json')

  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      local raw = table.concat(vim.fn.readfile(path), '\n')
      local ok, data = pcall(vim.json.decode, raw)
      if ok and type(data) == 'table' then
        for _, entry in pairs(data) do
          if type(entry) == 'table' and entry.oauth_token then
            return entry.oauth_token
          end
        end
      end
    end
  end
  return nil
end

--- curl executable — use curl.exe on Windows to avoid the PowerShell alias.
local function curl_cmd()
  return vim.fn.has('win32') == 1 and 'curl.exe' or 'curl'
end

--- Exchange the long-lived OAuth token for a short-lived Copilot session token.
local function refresh_token(callback)
  local oauth = get_oauth_token()
  if not oauth then
    vim.notify(
      'Copilot Chat: No OAuth token found.\nRun  :Copilot auth  to authenticate first.',
      vim.log.levels.ERROR
    )
    return
  end

  local pending = ''
  vim.fn.jobstart({
    curl_cmd(), '-sS',
    '-H', 'Authorization: token ' .. oauth,
    '-H', 'Accept: application/json',
    '-H', 'User-Agent: GithubCopilot/1.155.0',
    'https://api.github.com/copilot_internal/v2/token',
  }, {
    on_stdout = function(_, data)
      -- Standard partial-line buffering
      data[1] = pending .. data[1]
      pending = data[#data]
      for i = 1, #data - 1 do
        local line = data[i]
        if line ~= '' then
          local ok, resp = pcall(vim.json.decode, line)
          if ok and resp.token then
            state.session_token = resp.token
            -- expires_at may be number (epoch) or string — be defensive
            local exp = resp.expires_at
            state.token_expires_at = (type(exp) == 'number' and exp) or (os.time() + 1500)
            vim.schedule(function() callback(resp.token) end)
          elseif ok and resp.message then
            vim.schedule(function()
              vim.notify('Copilot Chat: Token error — ' .. resp.message, vim.log.levels.ERROR)
            end)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      local err = vim.trim(table.concat(data, ''))
      if err ~= '' then
        vim.schedule(function()
          vim.notify('Copilot Chat: curl error during auth — ' .. err, vim.log.levels.ERROR)
        end)
      end
    end,
  })
end

--- Ensure a valid session token, then invoke callback(token).
local function with_token(callback)
  if state.session_token and os.time() < (state.token_expires_at - 60) then
    callback(state.session_token)
  else
    refresh_token(callback)
  end
end

-- ═══════════════════════════════════════════════════════════════════════
-- Streaming Chat Completions
-- ═══════════════════════════════════════════════════════════════════════

local function send_to_api(token, on_chunk, on_done, on_error)
  local body = vim.json.encode({
    model = M.config.model,
    messages = state.messages,
    stream = true,
    temperature = 0.1,
    n = 1,
  })

  -- Write body to a temp file so we never have to shell-escape JSON.
  local tmpfile = vim.fn.tempname()
  vim.fn.writefile({ body }, tmpfile)

  local pending = ''

  state.current_job = vim.fn.jobstart({
    curl_cmd(), '-sS', '--no-buffer',
    '-X', 'POST',
    '-H', 'Authorization: Bearer ' .. token,
    '-H', 'Content-Type: application/json',
    '-H', 'Editor-Version: Neovim/' .. tostring(vim.version()),
    '-H', 'Copilot-Integration-Id: vscode-chat',
    '-H', 'OpenAI-Intent: conversation-panel',
    '-d', '@' .. tmpfile,
    'https://api.githubcopilot.com/chat/completions',
  }, {
    on_stdout = function(_, data)
      data[1] = pending .. data[1]
      pending = data[#data]

      for i = 1, #data - 1 do
        local line = data[i]
        if line:match('^data: ') then
          local payload = line:sub(7)
          if payload == '[DONE]' then
            vim.schedule(on_done)
          else
            local ok, chunk = pcall(vim.json.decode, payload)
            if ok and chunk.choices and chunk.choices[1] then
              local delta = chunk.choices[1].delta
              if delta and delta.content then
                local content = delta.content
                vim.schedule(function() on_chunk(content) end)
              end
            end
          end
        elseif line:match('^{') then
          -- Possible non-streaming error envelope
          local ok, obj = pcall(vim.json.decode, line)
          if ok and obj.error then
            vim.schedule(function()
              on_error(obj.error.message or vim.inspect(obj.error))
            end)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      local err = vim.trim(table.concat(data, ''))
      if err ~= '' then
        vim.schedule(function() on_error('curl: ' .. err) end)
      end
    end,
    on_exit = function()
      vim.fn.delete(tmpfile)
      state.current_job = nil
      state.streaming = false
    end,
  })
end

-- ═══════════════════════════════════════════════════════════════════════
-- UI helpers
-- ═══════════════════════════════════════════════════════════════════════

local function buf_ok(b) return b and vim.api.nvim_buf_is_valid(b) end
local function win_ok(w) return w and vim.api.nvim_win_is_valid(w) end

--- Append text (may contain newlines) at the very end of the chat buffer.
local function chat_append(text)
  if not buf_ok(state.chat_buf) then return end

  vim.bo[state.chat_buf].modifiable = true
  local parts = vim.split(text, '\n', { plain = true })
  local count = vim.api.nvim_buf_line_count(state.chat_buf)
  local last  = vim.api.nvim_buf_get_lines(state.chat_buf, count - 1, count, false)[1] or ''

  -- Merge first fragment onto the current last line
  vim.api.nvim_buf_set_lines(state.chat_buf, count - 1, count, false, { last .. parts[1] })

  -- Append remaining complete lines
  if #parts > 1 then
    local rest = {}
    for i = 2, #parts do rest[#rest + 1] = parts[i] end
    vim.api.nvim_buf_set_lines(state.chat_buf, count, count, false, rest)
  end

  -- Auto-scroll
  if win_ok(state.chat_win) then
    local new_count = vim.api.nvim_buf_line_count(state.chat_buf)
    vim.api.nvim_win_set_cursor(state.chat_win, { new_count, 0 })
  end
end

--- Overwrite the chat buffer entirely.
local function chat_set(lines)
  if not buf_ok(state.chat_buf) then return end
  vim.bo[state.chat_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.chat_buf, 0, -1, false, lines)
end

-- ═══════════════════════════════════════════════════════════════════════
-- Buffer / Window management
-- ═══════════════════════════════════════════════════════════════════════

local function ensure_chat_buf()
  if buf_ok(state.chat_buf) then return state.chat_buf end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, 'copilot-chat://chat')
  vim.bo[buf].filetype  = 'markdown'
  vim.bo[buf].buftype   = 'nofile'
  vim.bo[buf].swapfile  = false
  vim.bo[buf].buflisted = false
  state.chat_buf = buf
  return buf
end

local function ensure_input_buf()
  if buf_ok(state.input_buf) then return state.input_buf end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, 'copilot-chat://input')
  vim.bo[buf].buftype   = 'nofile'
  vim.bo[buf].swapfile  = false
  vim.bo[buf].filetype  = 'markdown'
  vim.bo[buf].buflisted = false
  state.input_buf = buf
  return buf
end

local function setup_buf_keymaps()
  -- ── Input buffer ──────────────────────────────────────────────────
  local iopts = { buffer = state.input_buf, noremap = true, silent = true }
  vim.keymap.set('n', '<CR>',  function() M.send() end, iopts)
  vim.keymap.set('i', '<C-CR>', function() vim.cmd('stopinsert'); M.send() end, iopts)
  vim.keymap.set({ 'n', 'i' }, '<C-s>', function() vim.cmd('stopinsert'); M.send() end, iopts)
  vim.keymap.set('n', 'q',  function() M.close() end, iopts)
  vim.keymap.set('n', 'gm', function() M.pick_model() end, iopts)
  vim.keymap.set('n', 'gr', function() M.reset() end, iopts)
  vim.keymap.set('n', 'gs', function() M.stop() end, iopts)

  -- ── Chat buffer ───────────────────────────────────────────────────
  local copts = { buffer = state.chat_buf, noremap = true, silent = true }
  vim.keymap.set('n', 'q',  function() M.close() end, copts)
  vim.keymap.set('n', 'gm', function() M.pick_model() end, copts)
  vim.keymap.set('n', 'gr', function() M.reset() end, copts)
  vim.keymap.set('n', 'gs', function() M.stop() end, copts)
  vim.keymap.set('n', 'i', function()
    if win_ok(state.input_win) then
      vim.api.nvim_set_current_win(state.input_win)
      vim.cmd('startinsert')
    end
  end, copts)
end

-- ═══════════════════════════════════════════════════════════════════════
-- Public API
-- ═══════════════════════════════════════════════════════════════════════

function M.open()
  if win_ok(state.chat_win) then
    if win_ok(state.input_win) then vim.api.nvim_set_current_win(state.input_win) end
    return
  end

  local chat_buf  = ensure_chat_buf()
  local input_buf = ensure_input_buf()

  -- Right-side vertical split → chat
  vim.cmd('botright vsplit')
  state.chat_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.chat_win, chat_buf)
  vim.api.nvim_win_set_width(state.chat_win, M.config.chat_width)
  vim.wo[state.chat_win].wrap           = true
  vim.wo[state.chat_win].linebreak      = true
  vim.wo[state.chat_win].number         = false
  vim.wo[state.chat_win].relativenumber = false
  vim.wo[state.chat_win].signcolumn     = 'no'
  vim.wo[state.chat_win].cursorline     = false
  vim.wo[state.chat_win].conceallevel   = 2

  -- Horizontal split below chat → input
  vim.cmd('belowright split')
  state.input_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.input_win, input_buf)
  vim.api.nvim_win_set_height(state.input_win, M.config.input_height)
  vim.wo[state.input_win].wrap           = true
  vim.wo[state.input_win].linebreak      = true
  vim.wo[state.input_win].number         = false
  vim.wo[state.input_win].relativenumber = false
  vim.wo[state.input_win].signcolumn     = 'no'

  setup_buf_keymaps()

  -- Welcome header on first open
  if vim.api.nvim_buf_line_count(chat_buf) <= 1
    and (vim.api.nvim_buf_get_lines(chat_buf, 0, 1, false)[1] or '') == '' then
    chat_set({
      '# Copilot Chat  (' .. M.config.model .. ')',
      '',
      '_Type in the input buffer below, then press_ `<CR>` _(normal) or_ `<C-s>` _to send._',
      '_`gm` switch model  `gr` reset  `gs` stop  `q` close_',
      '',
      '---',
      '',
    })
  end

  -- Clean up both windows when either is closed externally
  local augroup = vim.api.nvim_create_augroup('CopilotChatWinClose', { clear = true })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = augroup,
    callback = function(ev)
      local closed = tonumber(ev.match)
      if closed == state.chat_win or closed == state.input_win then
        vim.schedule(function() M.close() end)
      end
    end,
  })

  vim.api.nvim_set_current_win(state.input_win)
  vim.cmd('startinsert')
end

function M.close()
  if state.current_job then
    vim.fn.jobstop(state.current_job)
    state.current_job = nil
    state.streaming = false
  end
  -- Close input first (it's nested inside the chat column)
  if win_ok(state.input_win) then pcall(vim.api.nvim_win_close, state.input_win, true) end
  if win_ok(state.chat_win)  then pcall(vim.api.nvim_win_close, state.chat_win, true)  end
  state.chat_win  = nil
  state.input_win = nil
  pcall(vim.api.nvim_del_augroup_by_name, 'CopilotChatWinClose')
end

function M.toggle()
  if win_ok(state.chat_win) then M.close() else M.open() end
end

--- Send the content of the input buffer (or the supplied text) as a user message.
function M.send(text)
  if state.streaming then
    vim.notify('Copilot Chat: Still streaming — press gs to stop.', vim.log.levels.WARN)
    return
  end

  -- Read from input buffer when no text is supplied
  if not text then
    if not buf_ok(state.input_buf) then return end
    local lines = vim.api.nvim_buf_get_lines(state.input_buf, 0, -1, false)
    text = table.concat(lines, '\n')
    vim.api.nvim_buf_set_lines(state.input_buf, 0, -1, false, { '' })
  end

  text = vim.trim(text)
  if text == '' then return end

  -- First message gets a system prompt
  if #state.messages == 0 then
    table.insert(state.messages, { role = 'system', content = M.config.system_prompt })
  end
  table.insert(state.messages, { role = 'user', content = text })

  -- Render in chat
  chat_append('## You\n\n' .. text .. '\n\n')
  chat_append('## Copilot (' .. M.config.model .. ')\n\n')

  state.streaming = true
  local response_parts = {}

  with_token(function(token)
    send_to_api(
      token,
      function(content)                         -- on_chunk
        response_parts[#response_parts + 1] = content
        chat_append(content)
      end,
      function()                                -- on_done
        local full = table.concat(response_parts, '')
        table.insert(state.messages, { role = 'assistant', content = full })
        chat_append('\n\n---\n\n')
        state.streaming = false
      end,
      function(err)                             -- on_error
        chat_append('\n\n**Error:** ' .. err .. '\n\n---\n\n')
        vim.notify('Copilot Chat: ' .. err, vim.log.levels.ERROR)
        state.streaming = false
      end
    )
  end)
end

--- Open chat and ask a question, optionally with code context.
function M.ask(prompt, context)
  M.open()
  if context and context ~= '' then
    local ft = vim.bo.filetype or ''
    prompt = (prompt or '') .. '\n\n```' .. ft .. '\n' .. context .. '\n```'
  end
  if prompt and vim.trim(prompt) ~= '' then
    M.send(prompt)
  end
end

--- Stop the current streaming response.
function M.stop()
  if state.current_job then
    vim.fn.jobstop(state.current_job)
    state.current_job = nil
    state.streaming = false
    chat_append('\n\n_[Stopped]_\n\n---\n\n')
    vim.notify('Copilot Chat: response stopped')
  end
end

--- Pick a model via vim.ui.select.
function M.pick_model()
  vim.ui.select(M.config.available_models, {
    prompt = 'Select model:',
    format_item = function(m)
      return m == M.config.model and (m .. '  (current)') or m
    end,
  }, function(choice)
    if not choice then return end
    M.config.model = choice
    vim.notify('Copilot Chat: model -> ' .. choice)
    -- Update the header
    if buf_ok(state.chat_buf) then
      local first = vim.api.nvim_buf_get_lines(state.chat_buf, 0, 1, false)[1] or ''
      if first:match('^# Copilot Chat') then
        vim.bo[state.chat_buf].modifiable = true
        vim.api.nvim_buf_set_lines(state.chat_buf, 0, 1, false,
          { '# Copilot Chat  (' .. choice .. ')' })
      end
    end
  end)
end

--- Clear the conversation history and chat buffer.
function M.reset()
  state.messages = {}
  if state.current_job then
    vim.fn.jobstop(state.current_job)
    state.current_job = nil
    state.streaming = false
  end
  if buf_ok(state.chat_buf) then
    chat_set({
      '# Copilot Chat  (' .. M.config.model .. ')',
      '',
      '_Conversation reset._',
      '',
      '---',
      '',
    })
  end
  vim.notify('Copilot Chat: conversation reset')
end

-- ═══════════════════════════════════════════════════════════════════════
-- Setup (called from the lazy.nvim spec)
-- ═══════════════════════════════════════════════════════════════════════

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Commands ------------------------------------------------------------------
  vim.api.nvim_create_user_command('CopilotChat', function()
    M.toggle()
  end, { desc = 'Toggle Copilot Chat' })

  vim.api.nvim_create_user_command('CopilotChatAsk', function(a)
    local ctx = ''
    if a.range > 0 then
      local lines = vim.api.nvim_buf_get_lines(0, a.line1 - 1, a.line2, false)
      ctx = table.concat(lines, '\n')
    end
    M.ask(a.args, ctx)
  end, { nargs = '*', range = true, desc = 'Ask Copilot Chat (supports visual selection)' })

  vim.api.nvim_create_user_command('CopilotChatModel', function()
    M.pick_model()
  end, { desc = 'Pick Copilot Chat model' })

  vim.api.nvim_create_user_command('CopilotChatReset', function()
    M.reset()
  end, { desc = 'Reset Copilot Chat conversation' })

  vim.api.nvim_create_user_command('CopilotChatStop', function()
    M.stop()
  end, { desc = 'Stop Copilot Chat response' })

  vim.api.nvim_create_user_command('CopilotChatClose', function()
    M.close()
  end, { desc = 'Close Copilot Chat window' })
end

return M
