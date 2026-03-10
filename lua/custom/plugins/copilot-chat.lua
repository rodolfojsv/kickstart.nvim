-- Copilot Chat — local plugin that talks to the GitHub Copilot API directly,
-- letting you chat with premium models (Claude Opus 4.6, etc.) using your
-- existing Copilot subscription.  No separate Anthropic key required.
--
-- Depends on copilot.lua being authenticated (:Copilot auth).

return {
  dir = vim.fn.stdpath('config'),
  name = 'copilot-chat-nvim',
  lazy = false,

  config = function()
    require('copilot-chat').setup({
      model = 'claude-opus-4.6', -- default model for new conversations
      available_models = {
        'claude-opus-4.6',
        'claude-sonnet-4',
        'gpt-4o',
        'o3-mini',
      },
      chat_width = 80,
      input_height = 5,
    })

    -- ── Keymaps ─────────────────────────────────────────────────────
    -- Using <leader>p* ("pilot") to avoid clashing with avante's <leader>c*
    vim.keymap.set('n', '<leader>pc', '<cmd>CopilotChat<CR>',      { desc = '[P]ilot [C]hat toggle' })
    vim.keymap.set('n', '<leader>pa', ':CopilotChatAsk ',          { desc = '[P]ilot Chat [A]sk' })
    vim.keymap.set('v', '<leader>pa', ':CopilotChatAsk ',          { desc = '[P]ilot Chat [A]sk with selection' })
    vim.keymap.set('n', '<leader>pm', '<cmd>CopilotChatModel<CR>', { desc = '[P]ilot Chat [M]odel' })
    vim.keymap.set('n', '<leader>pr', '<cmd>CopilotChatReset<CR>', { desc = '[P]ilot Chat [R]eset' })
    vim.keymap.set('n', '<leader>ps', '<cmd>CopilotChatStop<CR>',  { desc = '[P]ilot Chat [S]top' })
  end,
}
