local ls = require 'luasnip'
return {
  ls.config.set_config {
    updateevents = 'TextChanged,TextChangedI',
  },
}
