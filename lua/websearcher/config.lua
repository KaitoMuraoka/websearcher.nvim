local config = {
    open_cmd = "",
    search_engine = "Google",
    use_w3m = false,
    search_engines = {},
}

local default_search_engines = {
    Google = "https://google.com/search?q=",
    DuckDuckGo = "https://duckduckgo.com/?q=",
    Bing = "https://www.bing.com/search?q=",
    Yahoo = "https://search.yahoo.com/search?p=",
    Baidu = "https://www.baidu.com/s?wd=",
    Yandex = "https://yandex.com/search/?text=",
    Ask = "https://www.ask.com/web?q=",
    Ecosia = "https://www.ecosia.org/search?q=",
    Phind = "https://www.phind.com/search?q=",
    Wikipedia = "https://<lang>.wikipedia.org/w/index.php?search=",
    Perplexity = "https://www.perplexity.ai/search?q=",
    Brave = "https://search.brave.com/search?q=",
}

local M = {}

function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.get_config()
    return config
end

function M.get_default_search_engines()
    return default_search_engines
end

return M
