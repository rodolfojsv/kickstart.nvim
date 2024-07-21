local ls = require 'luasnip'
require 'snippets.basiccssnipppets'
require 'snippets.mongocssnippets'

return {
  ls.config.set_config {
    updateevents = 'TextChanged,TextChangedI',
  },
}
