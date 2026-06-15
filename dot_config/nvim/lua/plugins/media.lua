-- Media: inline image/GIF display and PDF viewing
-- Requires: brew install imagemagick poppler
return {
  -- Inline image and GIF rendering (Kitty graphics protocol — works with Ghostty)
  {
    "3rd/image.nvim",
    ft = { "markdown", "norg" },
    event = "BufReadPre *.png,*.jpg,*.jpeg,*.gif,*.webp,*.avif",
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
        },
      },
      max_height_window_percentage = 50,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
    },
  },

  -- PDF viewer: renders text content with pdftotext
  {
    dir = vim.fn.stdpath("config"),
    name = "pdf-viewer",
    config = function()
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "*.pdf",
        callback = function(args)
          local path = args.file
          local buf = args.buf
          vim.bo[buf].modifiable = true
          vim.bo[buf].readonly = false
          local lines = vim.fn.systemlist("pdftotext -layout " .. vim.fn.shellescape(path) .. " -")
          if vim.v.shell_error ~= 0 then
            lines = { "[pdf-viewer] pdftotext not found — run: brew install poppler" }
          end
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          vim.bo[buf].readonly = true
          vim.bo[buf].filetype = "text"
          vim.bo[buf].buftype = "nofile"
          vim.bo[buf].swapfile = false
        end,
      })
    end,
  },
}
