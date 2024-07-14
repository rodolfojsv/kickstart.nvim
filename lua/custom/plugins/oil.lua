return {
  'stevearc/oil.nvim',
  keys = {
    { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
  },
  config = function()
    require('oil').setup {
      skip_confirm_for_simple_edits = true,
      default_file_explorer = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == '..' or name == '.git' or name == '.DS_Store' or name == '.vs' or name == '.vscode' or name:endswith '.pdb' or name:endswith '.old'
        end,
      },
      win_options = {
        wrap = true,
      },
    }
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  end,
}
