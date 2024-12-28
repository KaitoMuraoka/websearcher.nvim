local M = {}

function M.url_encode(str)
    str = string.gsub(str, "([^0-9a-zA-Z !'()*._~-])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
    return str
end

function M.is_macos()
    return vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 or vim.fn.has("gui_mac") == 1
end

return M
