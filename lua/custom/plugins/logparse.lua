return {
  'rodolfojsv/LuaNeoParse',
  enabled = false, -- No accessible GitHub repository currently exists.
  -- dir = 'C:/Dev/LuaNeoParse', -- Local development
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
