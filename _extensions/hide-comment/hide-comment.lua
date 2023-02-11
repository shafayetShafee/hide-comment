--[[
MIT License

Copyright (c) 2023 Shafayet Khan Shafee

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--


local str = pandoc.utils.stringify
-- local p = quarto.log.output


-- `filter_lines` taken from https://github.com/jjallaire/code-visibility
function filter_lines(text, filter)
  local lines = pandoc.List()
  local code = text .. "\n"
  for line in code:gmatch("([^\r\n]*)[\r\n]") do
    if filter(line) then
      lines:insert(line)
    end
  end
  return table.concat(lines, "\n")
end

-- create escaped cmnt_directive_pattern
function escape_pattern(s)
  local escaped = ""
  for c in s:gmatch(".") do
    escaped = escaped .. "%" .. c
  end
  return escaped
end

-- function for applying comment_directive
local function apply_cmnt_directives(comment_directive)
  local line_filter = {
    CodeBlock = function(cb)
      if cb.classes:includes('cell-code') then
        for k, cd in ipairs(comment_directive) do
          -- local cmnt_directive_tbl = {"#>", "//>"}
          -- if has_value(cmnt_directive_tbl, str(cd)) then
            local cmnt_directive_pattern = "^" .. escape_pattern(str(cd))
            cb.text = filter_lines(cb.text, function(line)
              return not line:match(cmnt_directive_pattern)
              end)
          -- end
        end
        return cb
      end
    end
  }
  return line_filter
end

-- hide lines with comment directive
function Pandoc(doc)
  local meta = doc.meta
  local cd = meta['comment-directive']
  if cd then
    return doc:walk(apply_cmnt_directives(cd))
  end
end


