-- Neovim Options
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of word
opt.iskeyword:append("-")

-- Disable swapfile
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Decrease update time
opt.updatetime = 250
opt.timeoutlen = 300

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Scroll offset
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Show invisible characters
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Better display for messages
opt.cmdheight = 1

-- Don't show mode (lualine shows it)
opt.showmode = false

-- Mouse support
opt.mouse = "a"

-- Concealment for special characters
opt.conceallevel = 0

-- Pop-up menu height
opt.pumheight = 10
