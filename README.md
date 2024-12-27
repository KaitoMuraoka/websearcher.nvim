# Websearcher.nvim

Websearcher is an extension to Neovim that enables web searches from Neovim.

![preview.git](./assets/preview.gif)

## Getting Started

This section explains how to install Websearcher.

## Requirements

- macOS or Linux (or Windows)

Windows has not been tested.

### Installation

Lazy:

```lua
return {
	"KaitoMuraoka/websearcher.nvim"
}
```

## Setup

Below are the default options for the setup function.

```lua
config = {
-- The shell command to use to open the URL.
-- As an empty string, it defaults to your OS defaults("open" for macOS, "xdg-open" for Linux)
open_cmd = "",

-- Specify search url. Default is Google.
-- See the search_engine section for currently registered search engines
search_url = "https://google.com/search?q=",

-- Add custom search_engines
search_engines = {
    Google = "https://google.com/search?q=",
    DuckDuckGo = "https://duckduckgo.com/?q=",
    Bing = "https://www.bing.com/search?q=",
    Wikipedia = "https://<lang>.wikipedia.org/wiki/",
}

-- Use w3m
-- Default is false
use_w3m = false,
},
```

## Keymaps

```lua
vim.api.nvim_set_keymap("v", "<leader>ss", ":lua require('websearcher').search_selected()<CR>", { noremap = true, silent = true }) -- Search selected text with default engine.
vim.api.nvim_set_keymap("v", "<leader>se", ":lua require('websearcher').search_selected_with_engine()<CR>", { noremap = true, silent = true }) -- Search selected text choosing engine.
```

## Commands

```lua
WebsearchOnEngine -- Open a window with engines to search
```

To search on Wikipedia, use the following format:

```
search | en
```

Where "en" is the language code for the specific Wikipedia language version.

## License

This plugin is License under the MIT license.
