local config = require('websearcher.config')
local search = require('websearcher.search')
local ui = require('websearcher.ui')
local browser = require('websearcher.browser')

local M = {}

function M.setup(opts)
    config.setup(opts)
end

local function execute_commands(commands)
    for _, command in ipairs(commands) do
        if type(command) == "function" then
            command()
        else
            os.execute(command)
        end
    end
end

local function handle_search(input, engines, lang)
    local commands = search.get_search_cmds(input, engines, lang)
    execute_commands(commands)
end

local function prompt_and_search(prompt, is_multiple, engines_callback)
    ui.prompt_user(prompt, function(input)
        if is_multiple then
            engines_callback(function(engines)
                ui.prompt_for_language_code_if_needed(engines, function(lang)
                    handle_search(input, engines, lang)
                end)
            end)
        else
            local command = search.get_search_cmd(input)
            execute_commands({command})
        end
    end)
end

function M.search()
    prompt_and_search("Enter your search keyword: ", false)
end

function M.search_multiple()
    prompt_and_search("Enter your search keyword: ", true, M.select_search_engines)
end

function M.search_selected()
    local selection = ui.get_visual_selection()
    if selection and selection ~= "" then
        local command = search.get_search_cmd(selection)
        execute_commands({command})
    end
end

function M.search_selected_multiple()
    local selection = ui.get_visual_selection()
    if selection and selection ~= "" then
        M.select_search_engines(function(engines)
            ui.prompt_for_language_code_if_needed(engines, function(lang)
                local commands = search.get_search_cmds(selection, engines, lang)
                execute_commands(commands)
            end)
        end)
    end
end

function M.select_search_engine(callback)
    local search_engines = vim.tbl_extend("force", config.get_default_search_engines(), config.get_config().search_engines)

    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    pickers.new({}, {
        prompt_title = "Select Search Engine",
        finder = finders.new_table {
            results = vim.tbl_keys(search_engines),
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

function M.select_search_engines(callback)
    local search_engines = vim.tbl_extend("force", config.get_default_search_engines(), config.get_config().search_engines)
    local selected_engines = {}

    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    pickers.new({}, {
        prompt_title = "Select Search Engines",
        finder = finders.new_table {
            results = vim.tbl_keys(search_engines),
        },
        attach_mappings = function(prompt_bufnr, map)
            local function toggle_selection()
                local selection = action_state.get_selected_entry().value
                if vim.tbl_contains(selected_engines, selection) then
                    for i, engine in ipairs(selected_engines) do
                        if engine == selection then
                            table.remove(selected_engines, i)
                            break
                        end
                    end
                else
                    table.insert(selected_engines, selection)
                end
                local updated_title = "Selected: " .. table.concat(selected_engines, ", ")
                local picker = action_state.get_current_picker(prompt_bufnr)
                picker:set_prompt(updated_title)
            end

            map("i", "<CR>", toggle_selection)
            map("i", "<C-q>", function()
                actions.close(prompt_bufnr)
                callback(selected_engines)
            end)
            return true
        end,
    }):find()
end

function M.search_selected_with_engine()
    local selection = ui.get_visual_selection()
    if selection and selection ~= "" then
        M.select_search_engine(function(engine)
            ui.prompt_for_language_code_if_needed({engine}, function(lang)
                local command = search.get_search_cmd(selection, engine, lang)
                execute_commands({command})
            end)
        end)
    end
end

function M.search_selected_with_engines()
    local selection = ui.get_visual_selection()
    if selection and selection ~= "" then
        M.select_search_engines(function(engines)
            ui.prompt_for_language_code_if_needed(engines, function(lang)
                local commands = search.get_search_cmds(selection, engines, lang)
                execute_commands(commands)
            end)
        end)
    end
end

function M.select_search_engine_and_search()
    M.select_search_engine(function(engine)
        ui.prompt_for_language_code_if_needed({engine}, function(lang)
            ui.prompt_user("Enter your search keyword: ", function(input)
                if input and input ~= "" then
                    local command = search.get_search_cmd(input, engine, lang)
                    execute_commands({command})
                end
            end)
        end)
    end)
end

function M.select_search_engines_and_search()
    M.select_search_engines(function(engines)
        ui.prompt_for_language_code_if_needed(engines, function(lang)
            ui.prompt_user("Enter your search keyword: ", function(input)
                local commands = search.get_search_cmds(input, engines, lang)
                execute_commands(commands)
            end)
        end)
    end)
end

vim.api.nvim_create_user_command("WebsearchOnEngine", function()
    M.select_search_engine_and_search()
end, {})

vim.api.nvim_create_user_command("WebsearchOnEngines", function()
    M.select_search_engines_and_search()
end, {})

return M
