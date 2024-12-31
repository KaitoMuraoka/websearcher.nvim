local search = require('websearcher.search')

local M = {}

function M.prompt_for_language_code_if_needed(engines, callback)
    for _, engine in ipairs(engines) do
        if engine == "Wikipedia" then
            vim.ui.input({ prompt = "Enter language code (e.g., en, jp, es): " }, function(lang)
                callback(lang)
            end)
            return
        end
    end
    callback(nil)
end

function M.prompt_user(prompt, callback)
    vim.ui.input({ prompt = prompt }, function(input)
        if input and input ~= "" then
            callback(input)
        end
    end)
end

function M.get_visual_selection()
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

return M
