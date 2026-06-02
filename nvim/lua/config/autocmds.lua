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

-- Markdown: grid table tools (<leader>mg = convert pipe→grid, <leader>mr = realign grid)
local md_group = augroup("MarkdownTools", { clear = true })
autocmd("FileType", {
  group = md_group,
  pattern = "markdown",
  callback = function()
    local function wrap_cell(text, max_w)
      text = vim.trim(text):gsub("<br>%s*", "\n")
      if text == "" then return { "" } end
      local result = {}
      for _, segment in ipairs(vim.split(text, "\n", { plain = true })) do
        segment = vim.trim(segment)
        if segment ~= "" then
          local indent = segment:match("^%- ") and "  " or ""
          local words = vim.split(segment, " ", { plain = true })
          local cur = ""
          for _, word in ipairs(words) do
            if cur == "" then
              cur = word
            elseif #cur + 1 + #word <= max_w then
              cur = cur .. " " .. word
            else
              table.insert(result, cur)
              cur = indent .. word
            end
          end
          if cur ~= "" then table.insert(result, cur) end
        end
      end
      return #result > 0 and result or { "" }
    end

    local function convert_grid()
      local buf = vim.api.nvim_get_current_buf()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
      local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local s, e = cursor_line, cursor_line
      while s > 1 and all_lines[s - 1]:match("^%s*|") do s = s - 1 end
      while e < #all_lines and all_lines[e + 1] and all_lines[e + 1]:match("^%s*|") do e = e + 1 end
      local rows = {}
      for i = s, e do
        local line = all_lines[i]
        if not line:match("^%s*|%s*[-:]+%s*|") then
          local cells = {}
          for cell in line:gmatch("|([^|]*)") do table.insert(cells, vim.trim(cell)) end
          if cells[#cells] == "" then table.remove(cells) end
          if #cells > 0 then table.insert(rows, cells) end
        end
      end
      if #rows == 0 then vim.notify("No pipe table found under cursor", vim.log.levels.WARN); return end
      local num_cols = 0
      for _, row in ipairs(rows) do if #row > num_cols then num_cols = #row end end
      local win_w = vim.api.nvim_win_get_width(0)
      local MAX_W = math.max(10, math.floor((win_w - num_cols - 1) / num_cols) - 2)
      local fmt_rows = {}
      for _, row in ipairs(rows) do
        local fmt_row = {}
        for i = 1, num_cols do table.insert(fmt_row, wrap_cell(row[i] or "", MAX_W)) end
        table.insert(fmt_rows, fmt_row)
      end
      local col_w = {}
      for i = 1, num_cols do col_w[i] = 0 end
      for _, fmt_row in ipairs(fmt_rows) do
        for i, cell_lines in ipairs(fmt_row) do
          for _, ln in ipairs(cell_lines) do if #ln > col_w[i] then col_w[i] = #ln end end
        end
      end
      local function sep(fill)
        local parts = {}
        for i = 1, num_cols do table.insert(parts, string.rep(fill, col_w[i] + 2)) end
        return "+" .. table.concat(parts, "+") .. "+"
      end
      local function row_line(cells_at_li)
        local parts = {}
        for i = 1, num_cols do
          local txt = cells_at_li[i] or ""
          table.insert(parts, " " .. txt .. string.rep(" ", col_w[i] - #txt) .. " ")
        end
        return "|" .. table.concat(parts, "|") .. "|"
      end
      local out = { sep("-") }
      for ri, fmt_row in ipairs(fmt_rows) do
        local max_h = 0
        for _, cl in ipairs(fmt_row) do if #cl > max_h then max_h = #cl end end
        for li = 1, max_h do
          local at_li = {}
          for i = 1, num_cols do table.insert(at_li, (fmt_row[i] or { "" })[li] or "") end
          table.insert(out, row_line(at_li))
        end
        table.insert(out, sep(ri == 1 and "=" or "-"))
      end
      vim.api.nvim_buf_set_lines(buf, s - 1, e, false, out)
      vim.notify("Converted to grid table", vim.log.levels.INFO)
    end

    local function realign_grid()
      local buf = vim.api.nvim_get_current_buf()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
      local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local function is_grid(line) return line:match("^%s*[|+]") end
      local s, e = cursor_line, cursor_line
      while s > 1 and is_grid(all_lines[s - 1]) do s = s - 1 end
      while e < #all_lines and all_lines[e + 1] and is_grid(all_lines[e + 1]) do e = e + 1 end
      local grid_rows, pending = {}, {}
      for i = s, e do
        local line = all_lines[i]
        if line:match("^%s*%+") then
          if #pending > 0 then
            local num_cols = 0
            for _, l in ipairs(pending) do
              local n = 0
              for _ in l:gmatch("|([^|]*)") do n = n + 1 end
              if n - 1 > num_cols then num_cols = n - 1 end
            end
            local cols = {}
            for c = 1, num_cols do cols[c] = {} end
            for _, l in ipairs(pending) do
              local c = 0
              for cell in l:gmatch("|([^|]*)") do
                c = c + 1
                if c <= num_cols then
                  local raw = vim.trim(cell):gsub("<br>%s*", "\n")
                  for _, seg in ipairs(vim.split(raw, "\n", { plain = true })) do
                    local seg_t = vim.trim(seg)
                    if seg_t ~= "" then table.insert(cols[c], seg_t) end
                  end
                end
              end
            end
            local cells = {}
            for c = 1, num_cols do
              local parts, acc = {}, ""
              for _, t in ipairs(cols[c]) do
                if t:match("^%- ") then
                  if acc ~= "" then table.insert(parts, acc) end
                  acc = t
                else
                  acc = acc == "" and t or (acc .. " " .. t)
                end
              end
              if acc ~= "" then table.insert(parts, acc) end
              table.insert(cells, table.concat(parts, "\n"))
            end
            table.insert(grid_rows, { cells = cells, header = line:match("=") ~= nil })
            pending = {}
          end
        else
          table.insert(pending, line)
        end
      end
      if #grid_rows == 0 then vim.notify("No grid table found under cursor", vim.log.levels.WARN); return end
      local num_cols = 0
      for _, row in ipairs(grid_rows) do if #row.cells > num_cols then num_cols = #row.cells end end
      local win_w = vim.api.nvim_win_get_width(0)
      local MAX_W = math.max(10, math.floor((win_w - num_cols - 1) / num_cols) - 2)
      local fmt_rows, col_w = {}, {}
      for i = 1, num_cols do col_w[i] = 0 end
      for _, row in ipairs(grid_rows) do
        local fmt = {}
        for i = 1, num_cols do
          local wrapped = wrap_cell(row.cells[i] or "", MAX_W)
          table.insert(fmt, wrapped)
          for _, ln in ipairs(wrapped) do if #ln > col_w[i] then col_w[i] = #ln end end
        end
        table.insert(fmt_rows, { lines = fmt, header = row.header })
      end
      local function sep(fill)
        local parts = {}
        for i = 1, num_cols do table.insert(parts, string.rep(fill, col_w[i] + 2)) end
        return "+" .. table.concat(parts, "+") .. "+"
      end
      local function rowline(cells_at_li)
        local parts = {}
        for i = 1, num_cols do
          local txt = cells_at_li[i] or ""
          table.insert(parts, " " .. txt .. string.rep(" ", col_w[i] - #txt) .. " ")
        end
        return "|" .. table.concat(parts, "|") .. "|"
      end
      local out = { sep("-") }
      for _, row in ipairs(fmt_rows) do
        local max_h = 0
        for _, cl in ipairs(row.lines) do if #cl > max_h then max_h = #cl end end
        for li = 1, max_h do
          local at_li = {}
          for i = 1, num_cols do table.insert(at_li, (row.lines[i] or { "" })[li] or "") end
          table.insert(out, rowline(at_li))
        end
        table.insert(out, sep(row.header and "=" or "-"))
      end
      vim.api.nvim_buf_set_lines(buf, s - 1, e, false, out)
      vim.notify("Grid table realigned", vim.log.levels.INFO)
    end

    vim.api.nvim_buf_create_user_command(0, "GridTable", convert_grid, { desc = "Convert pipe table to grid table" })
    vim.api.nvim_buf_create_user_command(0, "GridRealign", realign_grid, { desc = "Realign grid table" })
    vim.keymap.set("n", "<leader>mg", convert_grid, { buffer = true, desc = "Convert to grid table" })
    vim.keymap.set("n", "<leader>mr", realign_grid, { buffer = true, desc = "Realign grid table" })
  end,
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
