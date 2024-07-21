local snippets = function()
  local ls = require 'luasnip'
  local s = ls.snippet
  local i = ls.insert_node
  local t = ls.text_node
  local c = ls.choice_node
  local extras = require 'luasnip.extras'
  local rep = extras.rep
  local fmta = require('luasnip.extras.fmt').fmta
  local f = ls.function_node

  local initializeProperties = function(index)
    return f(function(arg)
      local properties = {}

      for field in string.gmatch(tostring(arg[1][1]), '([^,]+)') do
        local fieldName = ''
        for word in string.gmatch(tostring(field), '%w+') do
          fieldName = word
        end

        local fieldInit = 'this.' .. fieldName .. ' = ' .. fieldName .. ';'

        table.insert(properties, fieldInit)
      end

      return properties
    end, { index })
  end
  local propertiesFiller = function(index)
    return f(function(arg)
      local properties = {}

      for field in string.gmatch(tostring(arg[1][1]), '([^,]+)') do
        local fieldName = 'public ' .. field .. ' {get; set;}'

        table.insert(properties, fieldName)
        table.insert(properties, '')
      end

      return properties
    end, { index })
  end

  local cs_snips = {
    s(
      'class',
      fmta(
        [[
        namespace <>;

        public class <>{

          <> 

          public <>(<>){
          <>
          }

        }
      ]],
        {
          i(1, 'Some.Namespace'),
          i(2, 'ClassName'),
          propertiesFiller(3),
          rep(2),
          i(3, 'string somefield'),
          initializeProperties(3),
        }
      )
    ),
    s(
      'ResponseFactory',
      fmta([[return ResponseFactory.<>(<>);]], {
        c(1, { t 'BuildResponse', t 'BuildDataResponse' }),
        i(0, 'ControllerResponse.BadRequest'),
      })
    ),
    s(
      'tryc',

      fmta(
        [[try {

<>

} catch (Exception ex)
{
<>
<>
}

]],
        { i(1), i(2, '_logger.LogError(ex.ToString());'), i(0, 'return something;') }
      )
    ),
  }

  ls.add_snippets('cs', cs_snips)
end

return {
  snippets(),
}
