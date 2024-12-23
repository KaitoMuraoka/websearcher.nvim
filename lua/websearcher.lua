local M = {}

local config = {
	open_cmd = "",
	search_engine = "Google",
}

local SearchEngineURLs = {
	Google = "https://google.com/search?q=",
	DuckDuckGo = "https://duckduckgo.com/?q=",
	Bing = "https://www.bing.com/search?q=",
}

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

--- Get the associated command for searching with the selected search engine
---@param query string
---@return string
local function get_search_cmd(query)
	local open_cmd = is_macos() and "open" or "xdg-open"
	if config.open_cmd ~= "" then
		open_cmd = config.open_cmd
	end

	local base_url = SearchEngineURLs[config.search_engine] or SearchEngineURLs.google
	local command = open_cmd .. " " .. base_url .. url_encode(query)
	return command
end

--- Setup the module with user-provided options
---@param opts table
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
end

--- Show a prompt to search using the configured search engine
function M.search()
	vim.ui.input({ prompt = "Enter your search keyword: " }, function(input)
		if input and input ~= "" then
			local command = get_search_cmd(input)
			os.execute(command)
		end
	end)
end

return M
