return {
  'stevearc/conform.nvim',
  lazy = true,
  keys = {
    {
      '<leader>f',
      function()
        -- vim.cmd 'Neoformat'
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    formatters = {
      csharpier = {
        args = { '--write-stdout', '--no-cache', '$FILENAME' },
      },
    },
    notify_on_error = false,
    -- format_on_save = function(bufnr)
    --   local disable_filetypes = { c = true, cpp = true }
    --   return {
    --     timeout_ms = 500,
    --     lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
    --   }
    -- end,
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { { 'prettierd', 'prettier' } },
      typescript = { 'deno_fmt' },
      cs = { 'csharpier' },
    },
  },
}
