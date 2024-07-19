local snippets = function()
  local ls = require 'luasnip'
  local s = ls.snippet
  local i = ls.insert_node
  local extras = require 'luasnip.extras'
  local rep = extras.rep
  local fmt = require('luasnip.extras.fmt').fmt

  local cs_snips = {
    s(
      'MongoUpdate',
      fmt(
        [[UpdateDefinition<{}> update = Builders<{}>.Update
                                                 .{}({});

FilterDefinition<{}> filter = Builders<{}>.Filter.Eq({});
]],
        { i(1, 'Entity'), rep(1), i(2, 'Action'), i(3, 'name, value'), rep(1), rep(1), i(0, 'name, value') }
      )
    ),
    s(
      'MongoUpdateWithFilter',
      fmt(
        [[UpdateDefinition<{}> update = Builders<{}>.Update
                                                 .{}({});

FilterDefinition<{}> filter = Builders<{}>.Filter.Eq({});

BsonDocumentArrayFilterDefinition<{}>[] arrayFilter = new BsonDocumentArrayFilterDefinition<{}>[]
{{
    new BsonDocumentArrayFilterDefinition<{}>(new BsonDocument("i._id", ObjectId.Parse({}))),
}};
]],
        { i(1, 'Entity'), rep(1), i(2, 'Action'), i(3, 'name, value'), rep(1), rep(1), i(4, 'name, value'), rep(1), rep(1), rep(1), i(0, 'Identifier') }
      )
    ),
  }

  ls.add_snippets('cs', cs_snips)
end

return {
  snippets(),
}
