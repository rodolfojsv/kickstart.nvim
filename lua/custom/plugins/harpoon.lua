return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require('harpoon')
    
    -- Setup harpoon with multiple lists
    harpoon:setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
      global = {
        -- Global list configuration
      },
      workspace = {
        -- Workspace-specific list configuration
      },
    })

    -- File to persist the current list choice
    local state_file = vim.fn.stdpath('data') .. '/harpoon_list_state.txt'

    -- Load the last used list from file
    local function load_list_state()
      local file = io.open(state_file, 'r')
      if file then
        local content = file:read('*all')
        file:close()
        if content == 'global' or content == 'workspace' then
          return content
        end
      end
      return 'workspace' -- default
    end

    -- Save the current list to file
    local function save_list_state(list_name)
      local file = io.open(state_file, 'w')
      if file then
        file:write(list_name)
        file:close()
      end
    end

    -- Track current active list (load from saved state)
    _G.harpoon_current_list = load_list_state()

    -- Helper function to get current list
    local function get_current_list()
      return harpoon:list(_G.harpoon_current_list)
    end

    -- Toggle between lists
    vim.keymap.set('n', '<leader>hl', function()
      if _G.harpoon_current_list == 'workspace' then
        _G.harpoon_current_list = 'global'
        print('Switched to global harpoon list')
      else
        _G.harpoon_current_list = 'workspace'
        print('Switched to workspace harpoon list')
      end
      save_list_state(_G.harpoon_current_list)
    end, { desc = 'Toggle harpoon list (workspace/global)' })

    -- Add file to current list
    vim.keymap.set('n', '<leader>ha', function()
      get_current_list():add()
      print('Added to ' .. _G.harpoon_current_list .. ' list')
    end, { desc = 'Add file to harpoon' })

    -- Toggle quick menu for current list
    vim.keymap.set('n', '<leader>hm', function()
      harpoon.ui:toggle_quick_menu(get_current_list())
    end, { desc = 'show file list' })

    -- Navigate to next file in current list
    vim.keymap.set('n', '<C-h>', function()
      get_current_list():next()
    end, { desc = 'go to next file' })

    -- Navigate to previous file in current list
    vim.keymap.set('n', '<C-l>', function()
      get_current_list():prev()
    end, { desc = 'go to previous file' })
  end,
}
