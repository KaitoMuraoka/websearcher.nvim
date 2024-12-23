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

-- Specify search engine. Default is Google.
-- See the search_engine section for currently registered search engines
search_engine = "Google",
},
```

### search_engine

- Google
- DuckDuckGo
- Bing

## License

This plugin is License under the MIT license.
