-- Extra plugins: WakaTime, LeetCode, Session management, CMake
return {
  -- WakaTime (coding time tracker)
  {
    "wakatime/vim-wakatime",
    event = "VeryLazy",
  },

  -- LeetCode (start with: nvim leetcode.nvim)
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    lazy = false,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>lc", "<cmd>Leet<cr>", desc = "Open LeetCode" },
      { "<leader>ll", "<cmd>Leet list<cr>", desc = "List problems" },
      { "<leader>lr", "<cmd>Leet run<cr>", desc = "Run code" },
      { "<leader>ls", "<cmd>Leet submit<cr>", desc = "Submit solution" },
      { "<leader>lp", "<cmd>Leet desc<cr>", desc = "Problem description" },
    },
    opts = {
      arg = "leetcode.nvim",
      lang = "cpp",
      cn = { enabled = false },
      logging = true,
      description = {
        position = "left",
        width = "40%",
      },
    },
  },

  -- Session management
  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      { "<leader>ss", "<cmd>SessionSave<cr>", desc = "Save session" },
      { "<leader>sr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
      { "<leader>sd", "<cmd>SessionDelete<cr>", desc = "Delete session" },
      { "<leader>sf", "<cmd>SessionSearch<cr>", desc = "Search sessions" },
    },
    opts = {
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Downloads", "/", "~/Documents/GitHub" },
      auto_session_use_git_branch = false,
      auto_save_enabled = true,
      auto_restore_enabled = false,
      auto_session_enable_last_session = false,
      session_lens = {
        buftypes_to_ignore = {},
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
      },
    },
  },

  -- CMake tools
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "cpp", "c", "cmake" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>cg", "<cmd>CMakeGenerate<cr>", desc = "CMake Generate" },
      { "<leader>cB", "<cmd>CMakeBuild<cr>", desc = "CMake Build" },
      { "<leader>cR", "<cmd>CMakeRun<cr>", desc = "CMake Run" },
      { "<leader>cD", "<cmd>CMakeDebug<cr>", desc = "CMake Debug" },
      { "<leader>cs", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake Select Build Type" },
      { "<leader>cT", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake Select Target" },
    },
    opts = {
      cmake_command = "cmake",
      cmake_regenerate_on_save = true,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_build_options = {},
      cmake_build_directory = "build/${variant:buildType}",
      cmake_soft_link_compile_commands = true,
      cmake_compile_commands_from_lsp = false,
      cmake_kits_path = nil,
      cmake_variants_message = {
        short = { show = true },
        long = { show = true, max_length = 40 },
      },
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
        console = "integratedTerminal",
      },
      cmake_executor = {
        name = "quickfix",
        opts = {},
        default_opts = {
          quickfix = {
            show = "always",
            position = "belowright",
            size = 10,
            encoding = "utf-8",
            auto_close_when_success = true,
          },
        },
      },
      cmake_runner = {
        name = "terminal",
        opts = {},
        default_opts = {
          terminal = {
            name = "CMake Terminal",
            prefix_name = "[CMakeTools]: ",
            split_direction = "horizontal",
            split_size = 11,
            single_terminal_per_instance = true,
            single_terminal_per_tab = true,
            keep_terminal_static_location = true,
            start_insert = false,
            focus = true,
          },
        },
      },
      cmake_notifications = {
        runner = { enabled = true },
        executor = { enabled = true },
        spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        refresh_rate_ms = 100,
      },
    },
  },

  -- Persistence (alternative session management - simpler)
  -- Uncomment if you prefer this over auto-session
  -- {
  --   "folke/persistence.nvim",
  --   event = "BufReadPre",
  --   opts = { options = vim.opt.sessionoptions:get() },
  --   keys = {
  --     { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
  --     { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
  --     { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  --   },
  -- },
}
