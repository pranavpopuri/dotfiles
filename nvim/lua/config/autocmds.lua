-- Auto commands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General settings group
local general = augroup("General", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
  group = general,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove whitespace on save
autocmd("BufWritePre", {
  group = general,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = general,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = general,
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto resize splits when window is resized
autocmd("VimResized", {
  group = general,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Language-specific settings
local lang_group = augroup("LanguageSettings", { clear = true })

-- C/C++ settings
autocmd("FileType", {
  group = lang_group,
  pattern = { "cpp", "c", "h", "hpp" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.commentstring = "// %s"
  end,
})

-- Rust settings
autocmd("FileType", {
  group = lang_group,
  pattern = { "rust" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

-- Python settings
autocmd("FileType", {
  group = lang_group,
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

-- Disable automatic comment continuation
autocmd("FileType", {
  group = general,
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Auto-generate compile_commands.json when opening a CMake project
local cmake_group = augroup("CMakeAutoGenerate", { clear = true })
autocmd({ "VimEnter", "DirChanged" }, {
  group = cmake_group,
  callback = function()
    if vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 1 then
      vim.defer_fn(function()
        if vim.fn.exists(":CMakeGenerate") == 2 then
          vim.cmd("CMakeGenerate")
        end
      end, 500)
    end
  end,
})

-- Check if file changed outside of nvim
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = general,
  command = "checktime",
})

-- Auto-enter insert mode when focusing any window
autocmd("WinEnter", {
  group = general,
  pattern = "*",
  callback = function()
    local bt = vim.bo.buftype
    if bt == "terminal" then
      vim.schedule(function() vim.cmd("startinsert") end)
    elseif bt == "" and not vim.bo.readonly then
      vim.cmd("startinsert")
    end
  end,
})

-- Autosave on leaving insert mode or losing focus
autocmd({ "FocusLost", "InsertLeave", "TextChanged", "TextChangedI" }, {
  group = general,
  pattern = "*",
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})
