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
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

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
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      defaults = {
        path_display = custom_path_display,
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
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

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      mbe2_live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
