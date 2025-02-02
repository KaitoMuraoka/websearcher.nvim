local search = require('websearcher.search')

local sample_query = "Neovim"
local ja_lang = "ja"
local open_command = (vim.loop.os_uname().sysname == "Linux") and "xdg-open " or "open "

describe('Search Command', function ()
  it('When using the default engine, it return "Google + the input string"', function ()
    local result = search.get_search_cmd(sample_query)
    assert.are.equal(open_command .. "https://google.com/search?q=Neovim", result)
  end)

  it('When using a specific engine, it returns "Engine name + the input string." ', function ()
    local result = search.get_search_cmd(sample_query, "DuckDuckGo")
    assert.are.equal(open_command .. "https://duckduckgo.com/?q=Neovim", result)
  end)

  it('if the language is Japanese, "ja" is included in the Wikipedia search query.', function ()
    local result = search.get_search_cmd(sample_query, "Wikipedia", ja_lang)
    assert.are_equal(open_command .. "https://ja.wikipedia.org/w/index.php?search=Neovim", result)
  end)
end)

describe('Multiple search engines', function ()
  local engins = { "Google", "DuckDuckGo", "Wikipedia" }

  it('Returns the search command for each engine.', function ()
    local expected_results = {
     open_command .. "https://google.com/search?q=Neovim",
     open_command .. "https://duckduckgo.com/?q=Neovim",
     open_command .. "https://en.wikipedia.org/w/index.php?search=Neovim"
    }
    local result = search.get_search_cmds(sample_query, engins)
    assert.are.same(expected_results, result)
  end)

  it('if the language is Japanese, only the Wikipedia search will have "lang=ja"', function ()
    local expected_results = {
      open_command .. "https://google.com/search?q=Neovim",
      open_command .. "https://duckduckgo.com/?q=Neovim",
      open_command .. "https://ja.wikipedia.org/w/index.php?search=Neovim"
    }
    local result = search.get_search_cmds(sample_query, engins, ja_lang)
    assert.are.same(expected_results, result)
  end)
end)

