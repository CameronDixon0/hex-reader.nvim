local M = {}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {
    -- default options
    show_ascii = true,
    show_address = true,
  }, opts or {})
end

function M.open()
  -- run :%!xxd -g 2
  vim.cmd('%!xxd -g 2')

  -- create a new namespace for your plugin's virtual text
  local ns_id = vim.api.nvim_create_namespace("hex_reader")

  -- get current buffer
  local bufnr = vim.api.nvim_get_current_buf()

  -- get total line count
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  -- add virtual text to each line
  for i = 0, line_count - 1 do
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, i, -1, {
      virt_text = { { "Hello world", "Comment" } },
      virt_text_pos = "eol", -- put it at the end of the line
    })
  end
end

return M
