return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Helper function to detect if we're in NeoSMIB directory
    local function is_in_neosmib()
      local cwd = vim.fn.getcwd()
      return cwd:match('C:\\Dev\\NeoSMIB') ~= nil or cwd:match('C:/Dev/NeoSMIB') ~= nil
    end

    -- Path display function to trim paths after MBE2
    local function custom_path_display(opts, path)
      if is_in_neosmib() then
        local mbe2_index = path:find('MBE2')
        if mbe2_index then
          return path:sub(mbe2_index + 5)
        end
      end
      return path
    end

    -- [[ Configure Telescope ]]
    require('telescope').setup {
      defaults = {
        path_display = custom_path_display,
        -- Global file ignore patterns
        file_ignore_patterns = {
          "%.exe$", "%.dll$", "%.so$", "%.dylib$", "%.a$", "%.o$", "%.obj$",
          "%.pyc$", "%.class$", "%.pdf$", "%.zip$", "%.tar$", "%.gz$", "%.rar$", "%.7z$",
          "%.jpg$", "%.jpeg$", "%.png$", "%.gif$", "%.bmp$", "%.ico$",
          "%.mp3$", "%.mp4$", "%.avi$", "%.mov$", "%.wav$",
        },
      },
      pickers = {},
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'

    -- Wrapper functions for MBE2-specific searches
    local function mbe2_live_grep(opts)
      opts = opts or {}
      if is_in_neosmib() then
        opts.cwd = 'C:\\Dev\\NeoSMIB\\SMIB\\EGS\\ABS\\source\\Software\\MBE2'
      end
      builtin.live_grep(opts)
    end

    local function mbe2_find_files(opts)
      opts = opts or {}
      if is_in_neosmib() then
        opts.cwd = 'C:\\Dev\\NeoSMIB\\SMIB\\EGS\\ABS\\source\\Software\\MBE2'
        
        -- Create an entry maker that marks UnitTest entries
        local make_entry = require('telescope.make_entry')
        local original_maker = make_entry.gen_from_file(opts)
        
        opts.entry_maker = function(entry)
          local result = original_maker(entry)
          if not result then return nil end
          
          local path = result.value or result.filename or result.path or ""
          result.is_unittest = path:match("UnitTest") ~= nil
          
          return result
        end
        
        -- Use custom sorter that filters based on prompt
        local conf = require('telescope.config').values
        local original_sorter = conf.file_sorter(opts)
        
        opts.sorter = require('telescope.sorters').Sorter:new {
          scoring_function = function(self, prompt, line, entry)
            if not entry or not entry.ordinal then
              return -1
            end
            
            local is_unittest = entry.is_unittest or false
            
            -- Filter based on prompt
            if prompt and prompt ~= "" and prompt:match("^test_") then
              -- If prompt starts with test_, only show UnitTest entries
              if not is_unittest then
                return -1
              end
            else
              -- Otherwise, hide UnitTest entries
              if is_unittest then
                return -1
              end
            end
            
            -- Use original sorter for scoring with correct parameters
            return original_sorter:scoring_function(prompt, line, entry)
          end,
          highlighter = original_sorter.highlighter,
        }
      end
      builtin.find_files(opts)
    end


    local function mbe2_grep_string(opts)
      opts = opts or {}
      if is_in_neosmib() then
        opts.cwd = 'C:\\Dev\\NeoSMIB\\SMIB\\EGS\\ABS\\source\\Software\\MBE2'
      end
      builtin.grep_string(opts)
    end

    -- Standard keymaps
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', mbe2_find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', mbe2_grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', mbe2_live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      mbe2_live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}


