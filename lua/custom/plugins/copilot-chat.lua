return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = false, -- Disable inline suggestions (Chat only)
          auto_trigger = false,
        },
        panel = {
          enabled = false, -- Disable panel (using Chat instead)
        },
      }
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    cmd = { 'CopilotChat', 'CopilotChatToggle', 'CopilotChatExplain', 'CopilotChatReview', 'CopilotChatFix', 'CopilotChatOptimize', 'CopilotChatDocs', 'CopilotChatTests', 'CopilotChatFixDiagnostic', 'CopilotChatCommit', 'CopilotChatCommitStaged' },
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    opts = {
      debug = false,
      model = 'gpt-4o',
      temperature = 0.1,
      question_header = '## User ',
      answer_header = '## Copilot ',
      error_header = '## Error ',
      separator = '───',
      show_folds = true,
      show_help = true,
      auto_follow_cursor = true,
      auto_insert_mode = false,
      clear_chat_on_new_prompt = false,
      context = 'buffers',
      
      -- Set default mode to 'agent' instead of 'ask'
      -- Agent mode allows Copilot to perform actions, while ask mode only answers questions
      answer_mode = 'agent',
      
      prompts = {
        Explain = {
          prompt = '/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.',
        },
        Review = {
          prompt = '/COPILOT_REVIEW Review the selected code.',
        },
        Fix = {
          prompt = '/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.',
        },
        Optimize = {
          prompt = '/COPILOT_GENERATE Optimize the selected code to improve performance and readability.',
        },
        Docs = {
          prompt = '/COPILOT_GENERATE Please add documentation comment for the selection.',
        },
        Tests = {
          prompt = '/COPILOT_GENERATE Please generate tests for my code.',
        },
        FixDiagnostic = {
          prompt = 'Please assist with the following diagnostic issue in file:',
          selection = function(source)
            return require('CopilotChat.select').diagnostics(source)
          end,
        },
        Commit = {
          prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
          selection = function(source)
            return require('CopilotChat.select').gitdiff(source)
          end,
        },
        CommitStaged = {
          prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
          selection = function(source)
            return require('CopilotChat.select').gitdiff(source, true)
          end,
        },
      },
    },
    keys = {
      -- Toggle chat
      {
        '<leader>cc',
        '<cmd>CopilotChatToggle<cr>',
        desc = '[C]opilot [C]hat toggle',
        mode = { 'n', 'v' },
      },
      -- Quick question
      {
        '<leader>cq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = '[C]opilot [Q]uick chat',
        mode = { 'n', 'v' },
      },
      -- Prompt actions
      {
        '<leader>cp',
        function()
          local actions = require 'CopilotChat.actions'
          require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
        end,
        desc = '[C]opilot [P]rompt actions',
        mode = { 'n', 'v' },
      },
      -- Explain code
      {
        '<leader>ce',
        '<cmd>CopilotChatExplain<cr>',
        desc = '[C]opilot [E]xplain code',
        mode = { 'n', 'v' },
      },
      -- Review code
      {
        '<leader>cr',
        '<cmd>CopilotChatReview<cr>',
        desc = '[C]opilot [R]eview code',
        mode = { 'n', 'v' },
      },
      -- Fix code
      {
        '<leader>cf',
        '<cmd>CopilotChatFix<cr>',
        desc = '[C]opilot [F]ix code',
        mode = { 'n', 'v' },
      },
      -- Optimize code
      {
        '<leader>co',
        '<cmd>CopilotChatOptimize<cr>',
        desc = '[C]opilot [O]ptimize code',
        mode = { 'n', 'v' },
      },
      -- Generate docs
      {
        '<leader>cd',
        '<cmd>CopilotChatDocs<cr>',
        desc = '[C]opilot [D]ocs',
        mode = { 'n', 'v' },
      },
      -- Generate tests
      {
        '<leader>ct',
        '<cmd>CopilotChatTests<cr>',
        desc = '[C]opilot [T]ests',
        mode = { 'n', 'v' },
      },
      -- Fix diagnostic
      {
        '<leader>cD',
        '<cmd>CopilotChatFixDiagnostic<cr>',
        desc = '[C]opilot Fix [D]iagnostic',
        mode = { 'n', 'v' },
      },
      -- Commit message
      {
        '<leader>cm',
        '<cmd>CopilotChatCommit<cr>',
        desc = '[C]opilot Commit [M]essage',
        mode = { 'n', 'v' },
      },
      -- Commit staged
      {
        '<leader>cM',
        '<cmd>CopilotChatCommitStaged<cr>',
        desc = '[C]opilot Commit Staged [M]essage',
        mode = { 'n', 'v' },
      },
    },
    config = function(_, opts)
      local chat = require 'CopilotChat'
      
      -- Set up the chat
      chat.setup(opts)
      
      -- Set up autocommands
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-*',
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true
        end,
      })
    end,
  },
}
