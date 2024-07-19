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
                                                 .{}({}, {});

FilterDefinition<{}> filter = Builders<{}>.Filter.Eq({}, {});

{}.UpdateOne(filter, update);
]],
        { i(1, 'Entity'), rep(1), i(2, 'Action'), i(3, 'name'), i(4, 'value'), rep(1), rep(1), i(5, 'name'), i(6, 'value'), i(0, 'collection') }
      )
    ),
    s(
      'MongoUpdateWithFilter',
      fmt(
        [[UpdateDefinition<{}> update = Builders<{}>.Update
                                                 .{}({}, {});

FilterDefinition<{}> filter = Builders<{}>.Filter.Eq({}, {});

BsonDocumentArrayFilterDefinition<{}>[] arrayFilter = new BsonDocumentArrayFilterDefinition<{}>[]
{{
    new BsonDocumentArrayFilterDefinition<{}>(new BsonDocument("i._id", ObjectId.Parse({}))),
}};


{}.UpdateOne(filter, update, new UpdateOptions {{ ArrayFilters = arrayFilter }});
]],
        {
          i(1, 'Entity'),
          rep(1),
          i(2, 'Action'),
          i(3, 'name'),
          i(4, 'value'),
          rep(1),
          rep(1),
          i(5, 'name'),
          i(6, 'value'),
          rep(1),
          rep(1),
          rep(1),
          i(7, 'Identifier'),
          i(0, 'collection'),
        }
      )
    ),
    s(
      'MongoPull',
      fmt(
        [[UpdateDefinition<{}> update = Builders<{}>.Update
                                                 .PullFilter({}, Builders<{}>.Filter.Where({}));

FilterDefinition<{}> filter = Builders<{}>.Filter.Eq({}, {});

{}.UpdateOne(filter, update);
]],
        {
          i(1, 'Entity'),
          rep(1),
          i(2, 'ent => ent.Array'),
          i(3, 'ArrayEnt'),
          i(4, 'arrEnt => arrEnt.Where/arrEnt.SomeCondition'),
          rep(1),
          rep(1),
          i(5, 'name'),
          i(6, 'value'),
          i(0, 'collection'),
        }
      )
    ),
  }

  ls.add_snippets('cs', cs_snips)
end

return {
  snippets(),
}
