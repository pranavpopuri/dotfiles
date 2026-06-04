-- Keymaps
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize windows with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down (Alt+j/k to avoid conflict with LSP K)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)

-- Keep cursor centered when scrolling
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Clear search highlights
keymap("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Better paste (don't copy replaced text)
keymap("v", "p", '"_dP', opts)

-- Delete without copying
keymap("n", "x", '"_x', opts)

-- Increment/decrement numbers
keymap("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equal split size" })
keymap("n", "<leader>sx", ":close<CR>", { desc = "Close split" })

-- Tab management
keymap("n", "<leader>to", ":tabnew<CR>", { desc = "New tab" })
keymap("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })
keymap("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })
keymap("n", "<leader>tp", ":tabp<CR>", { desc = "Previous tab" })

-- Quick save and quit
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>Q", ":qa!<CR>", { desc = "Force quit all" })

-- Select all
keymap("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Better join lines (keep cursor position)
keymap("n", "J", "mzJ`z", opts)

-- Open help files
keymap("n", "<leader>?", ":e ~/.config/nvim/cheatsheet.txt<CR>", { desc = "Open cheatsheet" })
keymap("n", "<leader>hg", ":e ~/.config/nvim/guide.txt<CR>", { desc = "Open guide" })

-- Reload config / Restart
keymap("n", "<leader>R", ":wa | qa<CR>", { desc = "Save all and quit (restart)" })

-- Yank current file's directory to system clipboard
keymap("n", "<leader>yd", function()
  local dir = vim.fn.expand("%:p:h")
  vim.fn.setreg("+", dir)
  vim.notify("Copied: " .. dir)
end, { desc = "Yank current file's directory" })

-- Wiki
keymap("n", "<leader>r", ":e ~/Documents/wiki/index.md<CR>", { desc = "Open wiki" })

-- Diagnostics navigation
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Toggle diagnostics virtual text
local diagnostics_visible = true
keymap("n", "<leader>cd", function()
  diagnostics_visible = not diagnostics_visible
  vim.diagnostic.config({ virtual_text = diagnostics_visible })
  vim.notify("Diagnostics virtual text: " .. (diagnostics_visible and "ON" or "OFF"))
end, { desc = "Toggle diagnostics virtual text" })
