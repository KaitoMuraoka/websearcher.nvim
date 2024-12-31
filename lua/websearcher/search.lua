local config = require('websearcher.config')
local utils = require('websearcher.utils')
local browser = require('websearcher.browser')

local M = {}

function M.get_search_url(engine, lang)
    local search_engines = vim.tbl_extend("force", config.get_default_search_engines(), config.get_config().search_engines)
    local search_url = search_engines[engine or config.get_config().search_engine]
    if engine == "Wikipedia" then
        search_url = search_url:gsub("<lang>", lang or "en")
    end
    return search_url
end

function M.get_search_cmd(query, engine, lang)
    local search_url = M.get_search_url(engine, lang)
    local url = search_url .. utils.url_encode(query)
    return browser.get_open_command(url)
end

function M.get_search_cmds(query, engines, lang)
    local commands = {}
    for _, engine in ipairs(engines) do
        table.insert(commands, M.get_search_cmd(query, engine, lang))
    end
    return commands
end

return M
