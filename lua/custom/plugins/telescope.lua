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
        
        -- Create an entry maker that filters based on current prompt
        local make_entry = require('telescope.make_entry')
        local original_maker = make_entry.gen_from_file(opts)
        
        opts.entry_maker = function(entry)
          local result = original_maker(entry)
          if not result then return nil end
          
          -- Store original display function
          local original_display = result.display
          
          -- Create custom display that filters based on picker state
          result.display = function(entry_to_display)
            -- Get the picker to access the prompt
            local state = require('telescope.actions.state')
            local picker = state.get_current_picker(vim.api.nvim_get_current_buf())
            
            if picker then
              local prompt = picker:_get_prompt()
              local path = entry_to_display.value or entry_to_display.filename or entry_to_display.path or ""
              
              -- If prompt doesn't start with test_, filter out UnitTest paths
              if not prompt:match("^test_") and path:match("UnitTest") then
                return nil  -- Don't display this entry
              end
              
              -- If prompt starts with test_, only show UnitTest paths
              if prompt:match("^test_") and not path:match("UnitTest") then
                return nil  -- Don't display this entry
              end
            end
            
            if original_display then
              return original_display(entry_to_display)
            end
            return entry_to_display.value
          end
          
          return result
        end
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


