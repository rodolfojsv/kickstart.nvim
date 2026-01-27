return {
  -- Base copilot plugin (no Node.js required) - MUST load first
  {
    'zbirenbaum/copilot.lua',
    lazy = false, -- Load immediately on startup
    priority = 1000,
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = false, -- Disabled - using avante for AI features
          auto_trigger = false,
        },
        panel = {
          enabled = false,
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          ['.'] = false,
        },
      }
    end,
  },

  -- Avante.nvim - Cursor-like AI interface
  {
    'yetone/avante.nvim',
    lazy = true,
    version = false,
    init = function()
      -- Define signs before plugin loads
      vim.fn.sign_define('AvanteInputPromptSign', { text = '▶', texthl = 'Special' })
    end,
    opts = {
      -- Provider configuration
      provider = 'copilot', -- Use GitHub Copilot by default
      
      -- Alternative providers (requires API keys)
      -- provider = 'claude', -- Requires ANTHROPIC_API_KEY env variable
      -- provider = 'openai', -- Requires OPENAI_API_KEY env variable
      
      providers = {
        copilot = {
          endpoint = 'https://api.githubcopilot.com',
          model = 'gpt-4o', -- Claude not available through Copilot API for third-party tools
          timeout = 30000,
          temperature = 0,
          extra_request_body = {
            max_tokens = 4096,
          },
        },
        -- Claude direct access (requires ANTHROPIC_API_KEY environment variable)
        claude = {
          endpoint = 'https://api.anthropic.com',
          model = 'claude-sonnet-4-20250514',
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 8000,
          },
        },
      },
      
      behaviour = {
        auto_suggestions = true,
        auto_set_highlight_group = false, -- Disable auto highlight to avoid errors
        auto_set_keymaps = false, -- We're setting custom keymaps
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
      },
      
      highlights = {
        diff = {
          current = 'DiffText',
          incoming = 'DiffAdd',
        },
      },
      
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = 'co',
          theirs = 'ct',
          all_theirs = 'ca',
          both = 'cb',
          cursor = 'cc',
          next = ']x',
          prev = '[x',
        },
        suggestion = {
          accept = '<M-l>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
        jump = {
          next = ']]',
          prev = '[[',
        },
        submit = {
          normal = '<CR>',
          insert = '<C-s>',
        },
        sidebar = {
          apply_all = 'A',
          apply_cursor = 'a',
          switch_windows = '<Tab>',
          reverse_switch_windows = '<S-Tab>',
        },
      },
      
      hints = { enabled = true },
      
      windows = {
        position = 'right',
        wrap = true,
        width = 30,
        sidebar_header = {
          align = 'center',
          rounded = true,
        },
      },
    },
    
    -- Build steps for different platforms
    build = ':AvanteBuild', -- This will compile the plugin
    
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- Optional dependencies
      'nvim-tree/nvim-web-devicons', -- for file icons
      'zbirenbaum/copilot.lua', -- for copilot provider
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
    
    keys = {
      -- Main toggle
      {
        '<leader>aa',
        function()
          require('avante.api').ask()
        end,
        desc = '[A]vante [A]sk',
        mode = { 'n', 'v' },
      },
      
      -- Quick actions
      {
        '<leader>ar',
        function()
          require('avante.api').refresh()
        end,
        desc = '[A]vante [R]efresh',
        mode = 'v',
      },
      
      {
        '<leader>ae',
        function()
          require('avante.api').edit()
        end,
        desc = '[A]vante [E]dit',
        mode = { 'n', 'v' },
      },
      
      -- Toggle sidebar
      {
        '<leader>at',
        function()
          require('avante.api').toggle()
        end,
        desc = '[A]vante [T]oggle',
      },
      
      -- Focus on sidebar
      {
        '<leader>af',
        function()
          require('avante.api').focus()
        end,
        desc = '[A]vante [F]ocus',
      },
      
      -- Code-related prompts (similar to copilot-chat)
      {
        '<leader>ax',
        function()
          vim.ui.input({ prompt = 'Explain: ' }, function(input)
            if input then
              require('avante.api').ask { question = 'Explain this code:\n\n' .. input }
            end
          end)
        end,
        desc = '[A]vante E[x]plain code',
        mode = { 'n', 'v' },
      },
      
      {
        '<leader>af',
        function()
          require('avante.api').ask { question = 'Fix any bugs or issues in this code' }
        end,
        desc = '[A]vante [F]ix code',
        mode = { 'n', 'v' },
      },
      
      {
        '<leader>ao',
        function()
          require('avante.api').ask { question = 'Optimize this code for better performance and readability' }
        end,
        desc = '[A]vante [O]ptimize code',
        mode = { 'n', 'v' },
      },
      
      {
        '<leader>ad',
        function()
          require('avante.api').ask { question = 'Add documentation comments to this code' }
        end,
        desc = '[A]vante [D]ocument code',
        mode = { 'n', 'v' },
      },
      
      {
        '<leader>aT',
        function()
          require('avante.api').ask { question = 'Generate unit tests for this code' }
        end,
        desc = '[A]vante Generate [T]ests',
        mode = { 'n', 'v' },
      },
      
      -- Quick chat (like copilot-chat's ccq)
      {
        '<leader>aq',
        function()
          vim.ui.input({ prompt = 'Quick Question: ' }, function(input)
            if input and input ~= '' then
              require('avante.api').ask { question = input }
            end
          end)
        end,
        desc = '[A]vante [Q]uick question',
        mode = { 'n', 'v' },
      },
      
      -- Switch model on the fly
      {
        '<leader>am',
        function()
          local models = {
            'gpt-4o',
            'gpt-4o-mini',
            'o1-preview',
            'o1-mini',
            'gpt-4',
            'claude-sonnet',
            'claude-3.5-sonnet',
            'o3-mini',
          }
          vim.ui.select(models, {
            prompt = 'Select Model (Copilot):',
          }, function(choice)
            if choice then
              -- Update the copilot provider model
              local config = require('avante.config')
              config.providers.copilot.model = choice
              vim.notify('Switched to model: ' .. choice, vim.log.levels.INFO)
            end
          end)
        end,
        desc = '[A]vante Switch [M]odel',
        mode = { 'n', 'v' },
      },
      
      -- Switch provider (if you add API keys later)
      {
        '<leader>as',
        function()
          vim.ui.select({ 'copilot', 'claude', 'openai' }, {
            prompt = 'Select AI Provider:',
          }, function(choice)
            if choice then
              local config = require('avante.config')
              config.provider = choice
              vim.notify('Switched to provider: ' .. choice, vim.log.levels.INFO)
            end
          end)
        end,
        desc = '[A]vante [S]witch provider',
        mode = { 'n', 'v' },
      },
      
      -- Check Copilot usage (opens browser to GitHub settings)
      {
        '<leader>au',
        function()
          local url = 'https://github.com/settings/copilot'
          local cmd
          if vim.fn.has('win32') == 1 then
            cmd = 'start ' .. url
          elseif vim.fn.has('mac') == 1 then
            cmd = 'open ' .. url
          else
            cmd = 'xdg-open ' .. url
          end
          vim.fn.system(cmd)
          vim.notify('Opening Copilot usage page in browser', vim.log.levels.INFO)
        end,
        desc = '[A]vante Check [U]sage',
        mode = { 'n', 'v' },
      },
    },
  },
}
