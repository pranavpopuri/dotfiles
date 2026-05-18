-- UI Plugins: Theme, statusline, bufferline, dashboard, icons
return {
  -- Render markdown in-buffer (normal mode = rendered, insert mode = raw)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      render_modes = { "n", "c" },
      anti_conceal = { enabled = false },
      sign = { enabled = false },
      heading = { backgrounds = {} },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      -- Double-click enters insert mode (single click just moves cursor, stays rendered)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.shiftwidth = 4
          vim.opt_local.breakindent = true
          vim.opt_local.breakindentopt = "list:-1"
          vim.keymap.set("n", "<CR>", function()
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2] + 1
            local link
            local start = 1
            while true do
              local s, e, path = line:find("%[.-%]%((.-)%)", start)
              if not s then break end
              if col >= s and col <= e then link = path; break end
              start = e + 1
            end
            if not link then return end
            if link:match("^https?://") then
              vim.ui.open(link)
            elseif link:match("%.pdf$") then
              local path = vim.fn.fnamemodify(vim.fn.expand("%:p:h") .. "/" .. link, ":p")
              vim.fn.jobstart({ "open", path }, { detach = true })
            else
              vim.cmd("edit " .. vim.fn.fnamemodify(vim.fn.expand("%:p:h") .. "/" .. link, ":p"))
            end
          end, { buffer = true, silent = true, desc = "Follow markdown link" })
        end,
      })
    end,
  },

  -- Sonokai colorscheme
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.sonokai_transparent_background = 1
      vim.g.sonokai_better_performance = 1
    end,
  },

  -- Theme switcher (persistent colorscheme via :Themery)
  {
    "zaldih/themery.nvim",
    lazy = false,
    priority = 998,
    keys = {
      { "<leader>ft", "<cmd>Themery<CR>", desc = "Themes" },
    },
    config = function()
      require("themery").setup({
        livePreview = true,
        themes = {
          { name = "Sonokai Default",   colorscheme = "sonokai", before = [[vim.g.sonokai_style = "default"]] },
          { name = "Sonokai Atlantis",  colorscheme = "sonokai", before = [[vim.g.sonokai_style = "atlantis"]] },
          { name = "Sonokai Andromeda", colorscheme = "sonokai", before = [[vim.g.sonokai_style = "andromeda"]] },
          { name = "Sonokai Shusia",    colorscheme = "sonokai", before = [[vim.g.sonokai_style = "shusia"]] },
          { name = "Sonokai Maia",      colorscheme = "sonokai", before = [[vim.g.sonokai_style = "maia"]] },
          { name = "Sonokai Espresso",  colorscheme = "sonokai", before = [[vim.g.sonokai_style = "espresso"]] },
        },
      })
    end,
  },

  -- Icons (required by many plugins)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            -- LSP server name
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then
                  return ""
                end
                local names = {}
                for _, client in ipairs(clients) do
                  table.insert(names, client.name)
                end
                return " " .. table.concat(names, ", ")
              end,
              cond = function()
                return #vim.lsp.get_clients({ bufnr = 0 }) > 0
              end,
            },
            -- WakaTime coding time (if available)
            {
              function()
                return vim.fn.exists("*wakatime#statusline") == 1 and vim.fn["wakatime#statusline"]() or ""
              end,
              cond = function()
                return vim.fn.exists("*wakatime#statusline") == 1
              end,
            },
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "nvim-tree", "toggleterm", "lazy" },
      })
    end,
  },

  -- Buffer line (tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    },
    opts = {
      options = {
        mode = "buffers",
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    },
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons", "amansingh-afk/milli.nvim" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      local splash = require("config.boids_splash").generate()
      dashboard.section.header.val = splash.frames[1]

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua<CR>"),
        dashboard.button("l", "  LeetCode", ":Leet<CR>"),
        dashboard.button("s", "  Restore Session", ":SessionRestore<CR>"),
        dashboard.button("k", "  Keybindings", ":e ~/.config/nvim/cheatsheet.txt<CR>"),
        dashboard.button("p", "  Plugins", ":e ~/.config/nvim/plugins.txt<CR>"),
        dashboard.button("h", "  Guide", ":e ~/.config/nvim/guide.txt<CR>"),
        dashboard.button("w", "  Wiki", ":e ~/Documents/wiki/index.md<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      dashboard.config.layout = {
        { type = "padding", val = 0 },
        dashboard.section.header,
        { type = "padding", val = 0 },
        dashboard.section.buttons,
      }

      alpha.setup(dashboard.config)

      require("milli").alpha({ data = splash, loop = true })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "NvimTree",
          "Trouble",
          "lazy",
          "mason",
        },
      },
    },
  },

  -- Which-key (keybinding hints)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true, suggestions = 20 },
      },
      win = {
        border = "rounded",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      -- Register key groups
      wk.add({
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code/Build" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Help" },
        { "<leader>l", group = "LSP/LeetCode" },
        { "<leader>n", group = "Notifications" },
        { "<leader>r", group = "Rename" },
        { "<leader>s", group = "Split/Session" },
        { "<leader>t", group = "Tab/Terminal" },
        { "<leader>x", group = "Trouble" },
      })
    end,
  },

  -- LSP progress notifications
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },

  -- Notifications
  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 999,
    config = function()
      require("notify").setup({
        timeout = 3000,
        background_colour = "#1F1F28",
        render = "wrapped-compact",
        stages = "fade",
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
      })
      vim.notify = require("notify")
    end,
  },
}
