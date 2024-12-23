local websearcher = require("websearcher")
vim.api.nvim_create_user_command("Websearch", websearcher.search, {})
