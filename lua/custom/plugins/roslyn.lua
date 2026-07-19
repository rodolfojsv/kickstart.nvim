return {
  'seblyng/roslyn.nvim',
  ft = 'cs',
  dependencies = { 'mason-org/mason.nvim' },
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    broad_search = true,
    lock_target = true,
    choose_target = function(targets)
      -- Prefer the DotnetFramework solution when available
      return vim.iter(targets):find(function(target)
        if string.match(target, 'Smib_FLN_DotnetFramework%.sln') then
          return target
        end
      end)
    end,
  },
  init = function()
    -- Configure Roslyn LSP settings via vim.lsp.config
    vim.lsp.config('roslyn', {
      settings = {
        ['csharp|inlay_hints'] = {
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
        },
        ['csharp|code_lens'] = {
          dotnet_enable_references_code_lens = true,
        },
        ['csharp|completion'] = {
          dotnet_show_completion_items_from_unimported_namespaces = true,
        },
      },
    })
  end,
}
