return {
  -- For local development
  dir = vim.fn.expand('~/Dev/LuaNeoParse'),
  -- For GitHub version, comment out the line above and uncomment below:
  -- 'yourusername/LuaNeoParse',
  config = function()
    require('LuaNeoParse').setup({
      -- Optional: Customize keymaps
      -- keymap_sas = '<leader>lps',
      -- keymap_lol = '<leader>lpl',
      -- keymap_ol = '<leader>lpo',
      -- show_notifications = true,
    })
  end,
}
