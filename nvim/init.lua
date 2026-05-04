-- Neovim IDE Configuration
-- Main entry point

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Shim removed in Neovim 0.10+ that Telescope 0.1.x still calls
if not vim.treesitter.language.ft_to_lang then
  vim.treesitter.language.ft_to_lang = function(ft)
    local ok, lang = pcall(vim.treesitter.language.get_lang, ft)
    return ok and lang or ft
  end
end

-- Bootstrap lazy.nvim and load plugins
require("config.lazy")

-- Load configuration
require("config.options")
require("config.keymaps")
require("config.autocmds")
