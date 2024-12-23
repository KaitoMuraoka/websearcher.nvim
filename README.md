# Websearcher.nvim

Websearcher is an extension to Neovim that enables web searches from Neovim.

![preview.git](./assets/preview.gif)

## Getting Started

This section explains how to install Websearcher.

## Requirements

- macOS or Linux (or Windows)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)

Windows has not been tested.

### Installation

Lazy:

```lua
return {
	"KaitoMuraoka/websearcher.nvim"
}
```

Packer:

```lua
use "KaitoMuraoka/websearcher.nvim"
```

Below are the default options for the setup function.

```lua
config = {
-- The shell command to use to open the URL.
-- As an empty string, it defaults to your OS defaults("open" for macOS, "xdg-open" for Linux)
open_cmd = "",

-- Specify search engine. Default is Google.
-- See the search_engine section for currently registered search engines
search_engine = "Google",

--- Specify if want use w3m
--- Default is set to false.
use_w3m = true
},
```

### Commands

`Websearch:` Makes a search using the config.

`WebsearchOnEngine:` Use Telescope for choose the search engine to use. (Only on that search)

`WebsearchHistory:` See the history of searchs. (Only keeps 50 last search)

`WebsearchHistoryDelete:` Reset all history.

`WebsearchUseW3m:` Enable/disable the w3m usage.

### Keymaps

This is a simple example to search one text selected on visual mode:

`vim.api.nvim_set_keymap("v", "<leader>ss", ":lua require('websearcher').search_selected()<CR>", { noremap = true, silent = true })`

### Search Engine

- Google
- DuckDuckGo
- Bing
- Yahoo
- Baidu
- Yandex
- Ask
- Ecosia
- Phind
- Wikipedia

## License

This plugin is License under the MIT license.
