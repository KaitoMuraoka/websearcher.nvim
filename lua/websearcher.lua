local M = {}

local config = {
    open_cmd = "",
    search_engine = "Google",
    use_w3m = false,
}

local SearchEngineURLs = {
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
}

local search_history = {}

--- Telescope Integration
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

--- Save search to history
---@param query string
local function save_to_history(query)
    table.insert(search_history, 1, query)
    if #search_history > 50 then
        table.remove(search_history) -- Limit history to 50 items
    end
end

--- Load history from file
local function load_history()
    local file = vim.fn.stdpath('data') .. "/search_history.txt"
    local f = io.open(file, "r")
    if f then
        for line in f:lines() do
            table.insert(search_history, line)
        end
        f:close()
    end
end

--- Save history to file
local function save_history_to_file()
    local file = vim.fn.stdpath('data') .. "/search_history.txt"
    local f = io.open(file, "w")
    if f then
        for _, line in ipairs(search_history) do
            f:write(line .. "\n")
        end
        f:close()
    end
end

--- Encode the string as a URL
---@param str string
local function url_encode(str)
    str = string.gsub(str, "([^0-9a-zA-Z !'()*._~-])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
    return str
end

--- Check if the system is macOS
---@return boolean
local function is_macos()
    return vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 or vim.fn.has("gui_mac") == 1
end

--- Open a URL with w3m in a floating window
---@param url string
local function open_with_w3m(url)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    vim.fn.termopen("w3m " .. url, {
        on_exit = function()
            vim.api.nvim_win_close(win, true)
        end,
    })
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_command("startinsert")
end

--- Get the associated command for searching with the selected search engine
---@param query string
---@return string|function
local function get_search_cmd(query)
    local search_query, lang = query:match("^(.-)%s*|%s*(%w+)$")
    if config.search_engine == "Wikipedia" then
        lang = lang or "en" -- Default to English if no language is specified
        local base_url = SearchEngineURLs[config.search_engine]:gsub("<lang>", lang)
        local url = base_url .. url_encode(search_query)
        if config.use_w3m then
            return function() open_with_w3m(url) end
        else
            local open_cmd = is_macos() and "open" or "xdg-open"
            if config.open_cmd ~= "" then
                open_cmd = config.open_cmd
            end
            return open_cmd .. " " .. url
        end
    else
        local base_url = SearchEngineURLs[config.search_engine] or SearchEngineURLs.Google
        local url = base_url .. url_encode(query)
        if config.use_w3m then
            return function() open_with_w3m(url) end
        else
            local open_cmd = is_macos() and "open" or "xdg-open"
            if config.open_cmd ~= "" then
                open_cmd = config.open_cmd
            end
            return open_cmd .. " " .. url
        end
    end
end

--- Setup the module with user-provided options
---@param opts table
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
    load_history() -- Load history on setup
end

--- Show a prompt to search using the configured search engine
function M.search()
    vim.ui.input({ prompt = "Enter your search keyword: " }, function(input)
        if input and input ~= "" then
            save_to_history(input)
            save_history_to_file()
            local command = get_search_cmd(input)
            if type(command) == "function" then
                command()
            else
                os.execute(command)
            end
        end
    end)
end

--- Get a selected text in visual mode
---@return string
local function get_visual_selection()
  -- Get the start and end positions of the visual selection
	local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

  -- If it is a single line, adjust the columns
	if start_row == end_row then
		return vim.fn.getline(start_row):sub(start_col, end_col)
	end

  -- If it a multiple lines, capture the full text
	local lines = vim.fn.getline(start_row, end_row)
	lines[1] = lines[1]:sub(start_col)
	lines[#lines] = lines[#lines]:sub(1, end_col)
	return table.concat(lines, "\n")
end

--- Search the selected text in visual mode
function M.search_selected()
    local selection = get_visual_selection()
    pickers.new({}, {
        prompt_title = "Search for: " .. selection,
        finder = finders.new_table {
            results = vim.tbl_keys(SearchEngineURLs),
        },
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local search_engine = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                config.search_engine = search_engine
                print("Searching with " .. search_engine)
                -- Make the search with the selected search engine
                vim.defer_fn(function()
                    local command = get_search_cmd(selection)
                    if type(command) == "function" then
                        command()
                    else
                        os.execute(command)
                    end
                end, 100)
            end)
            return true
        end,
    }):find()
    if selection and selection ~= "" then
        save_to_history(selection)
        save_history_to_file()
        local command = get_search_cmd(selection)
        if type(command) == "function" then
            command()
        else
            os.execute(command)
        end
    end
end



--- Select a search engine using Telescope
function M.select_search_engine()
    local previous_search_engine = config.search_engine -- Save the previous search engine
    pickers.new({}, {
        prompt_title = "Select Search Engine",
        finder = finders.new_table {
            results = vim.tbl_keys(SearchEngineURLs),
        },
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                config.search_engine = selection -- Change the search engine
                print("Searching with " .. selection)
                -- Make the search with the selected search engine
                vim.defer_fn(function()
                    M.search()
                end, 100)
            end)
            return true
        end,
    }):find()
config.search_engine = previous_search_engine
end

--- Command to select search engine and only when the search engine is selected, search
function M.select_search_engine_and_search()
    M.select_search_engine()
end

--- Create user command for WebsearchOnEngine
vim.api.nvim_create_user_command("WebsearchOnEngine", function()
    M.select_search_engine_and_search()
end, {})

--- Create user command for Websearch History
vim.api.nvim_create_user_command("WebsearchHistory", function()
    pickers.new({}, {
        prompt_title = "Search History",
        finder = finders.new_table {
            results = search_history,
        },
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                print("Searching for " .. selection)
                -- Make the search with the selected history item
                vim.defer_fn(function()
                    local command = get_search_cmd(selection)
                    if type(command) == "function" then
                        command()
                    else
                        os.execute(command)
                    end
                end, 100)
            end)
            return true
        end,
    }):find()
end, {})

--- Create user command for delete search history
vim.api.nvim_create_user_command("WebsearchHistoryDelete", function()
    search_history = {}
    save_history_to_file()
    print("Search history deleted")
end, {})

return M
