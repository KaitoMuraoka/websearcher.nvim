local M = {}

local config = {
    open_cmd = "",
    search_url = "https://google.com/search?q=",
    use_w3m = false,
    search_engines = {
        Google = "https://google.com/search?q=",
        DuckDuckGo = "https://duckduckgo.com/?q=",
        Bing = "https://www.bing.com/search?q=",
        Wikipedia = "https://<lang>.wikipedia.org/wiki/",
    }
}

local function url_encode(str)
    str = string.gsub(str, "([^0-9a-zA-Z !'()*._~-])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
    return str
end

local function is_macos()
    return vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 or vim.fn.has("gui_mac") == 1
end

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

local function get_search_cmd(query, engine, lang)
    local search_url = engine and config.search_engines[engine] or config.search_url
    if engine == "Wikipedia" then
        search_url = search_url:gsub("<lang>", lang)
    end
    local url = search_url .. url_encode(query)
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

function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.search()
    vim.ui.input({ prompt = "Enter your search keyword: " }, function(input)
        if input and input ~= "" then
            local command = get_search_cmd(input)
            if type(command) == "function" then
                command()
            else
                os.execute(command)
            end
        end
    end)
end

local function get_visual_selection()
    local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
    local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

    if start_row == end_row then
        return vim.fn.getline(start_row):sub(start_col, end_col)
    end

    local lines = vim.fn.getline(start_row, end_row)
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
    return table.concat(lines, "\n")
end

function M.search_selected()
    local selection = get_visual_selection()
    if selection and selection ~= "" then
        local command = get_search_cmd(selection)
        if type(command) == "function" then
            command()
        else
            os.execute(command)
        end
    end
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

function M.select_search_engine(callback)
    pickers.new({}, {
        prompt_title = "Select Search Engine",
        finder = finders.new_table {
            results = vim.tbl_keys(config.search_engines),
        },
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                callback(selection)
            end)
            return true
        end,
    }):find()
end

function M.search_selected_with_engine()
    local selection = get_visual_selection()
    if selection and selection ~= "" then
        M.select_search_engine(function(engine)
            if engine == "Wikipedia" then
                vim.ui.input({ prompt = "Enter language code (e.g., en, jp, es): " }, function(lang)
                    if lang and lang ~= "" then
                        local command = get_search_cmd(selection, engine, lang)
                        if type(command) == "function" then
                            command()
                        else
                            os.execute(command)
                        end
                    end
                end)
            else
                local command = get_search_cmd(selection, engine)
                if type(command) == "function" then
                    command()
                else
                    os.execute(command)
                end
            end
        end)
    end
end

function M.select_search_engine_and_search()
    M.select_search_engine(function(engine)
        if engine == "Wikipedia" then
            vim.ui.input({ prompt = "Enter language code (e.g., en, jp, es): " }, function(lang)
                if lang and lang ~= "" then
                    vim.ui.input({ prompt = "Enter your search keyword: " }, function(input)
                        if input and input ~= "" then
                            local command = get_search_cmd(input, engine, lang)
                            if type(command) == "function" then
                                command()
                            else
                                os.execute(command)
                            end
                        end
                    end)
                end
            end)
        else
            vim.ui.input({ prompt = "Enter your search keyword: " }, function(input)
                if input and input ~= "" then
                    local command = get_search_cmd(input, engine)
                    if type(command) == "function" then
                        command()
                    else
                        os.execute(command)
                    end
                end
            end)
        end
    end)
end

vim.api.nvim_create_user_command("WebsearchOnEngine", function()
    M.select_search_engine_and_search()
end, {})

return M
