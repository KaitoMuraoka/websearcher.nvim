local config = require('websearcher.config')
local utils = require('websearcher.utils')

local M = {}

function M.open_with_w3m(url)
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

function M.get_open_command(url)
    local config = config.get_config()
    if config.use_w3m then
        return function() M.open_with_w3m(url) end
    else
        local open_cmd = utils.is_macos() and "open" or "xdg-open"
        if config.open_cmd ~= "" then
            open_cmd = config.open_cmd
        end
        return open_cmd .. " " .. url
    end
end

return M
