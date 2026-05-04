-- Terminal (toggleterm)
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm size=15 direction=horizontal<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Vertical terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = false,
      on_open = function(_)
        vim.cmd("startinsert!")
      end,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
      winbar = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Terminal keymaps
      function _G.set_terminal_keymaps()
        local term_opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], term_opts)
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], term_opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], term_opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], term_opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], term_opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], term_opts)
      end

      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function()
          set_terminal_keymaps()
          vim.cmd("startinsert")
        end,
      })

      -- Custom terminals
      local Terminal = require("toggleterm.terminal").Terminal

      -- Build terminal
      local build_term = Terminal:new({
        cmd = "",
        direction = "horizontal",
        size = 15,
        close_on_exit = false,
      })

      -- Build current file (C++, Rust, Python)
      function _G.build_file()
        local ft = vim.bo.filetype
        if ft == "cpp" or ft == "c" then
          local file = vim.fn.expand("%:p")
          local output = vim.fn.expand("%:p:r")
          build_term.cmd = string.format("clang++ -std=c++20 -Wall -Wextra -g %s -o %s && echo 'Build successful!'", file, output)
        elseif ft == "rust" then
          build_term.cmd = "cargo build && echo 'Build successful!'"
        elseif ft == "python" then
          vim.notify("Python: no build needed, use <leader>cr to run", vim.log.levels.INFO)
          return
        else
          vim.notify("No build command for filetype: " .. ft, vim.log.levels.WARN)
          return
        end
        build_term:toggle()
      end

      -- Build and run current file (C++, Rust, Python)
      function _G.build_run_file()
        local ft = vim.bo.filetype
        if ft == "cpp" or ft == "c" then
          local file = vim.fn.expand("%:p")
          local output = vim.fn.expand("%:p:r")
          build_term.cmd = string.format("clang++ -std=c++20 -Wall -Wextra -g %s -o %s && %s", file, output, output)
        elseif ft == "rust" then
          build_term.cmd = "cargo run"
        elseif ft == "python" then
          local file = vim.fn.expand("%:p")
          build_term.cmd = "python3 " .. file
        else
          vim.notify("No run command for filetype: " .. ft, vim.log.levels.WARN)
          return
        end
        build_term:toggle()
      end

      -- Test command (Rust: cargo test, Python: pytest)
      function _G.run_tests()
        local ft = vim.bo.filetype
        if ft == "rust" then
          build_term.cmd = "cargo test"
        elseif ft == "python" then
          build_term.cmd = "pytest"
        else
          vim.notify("No test command for filetype: " .. ft, vim.log.levels.WARN)
          return
        end
        build_term:toggle()
      end

      -- Keymaps for build (works for C++ and Rust)
      vim.keymap.set("n", "<leader>cb", "<cmd>lua build_file()<cr>", { desc = "Build file" })
      vim.keymap.set("n", "<leader>cr", "<cmd>lua build_run_file()<cr>", { desc = "Build & Run file" })
      vim.keymap.set("n", "<leader>ct", "<cmd>lua run_tests()<cr>", { desc = "Run tests (Rust/Python)" })
    end,
  },
}
