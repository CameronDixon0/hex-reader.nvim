local M = {}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {
    -- default options
    show_ascii = true,
    show_address = true,
  }, opts or {})
end

function M.read_next_8_bytes()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1  -- Lua is 0-indexed

  local line = vim.api.nvim_get_current_line()

  -- Start of hex bytes in xxd format is at column 10
  local hex_start = 10

  -- Calculate byte index from cursor column
  local byte_index = math.floor((col - hex_start) / 3)

  -- Read 8 bytes from that position
  local bytes = {}
  for i = 0, 7 do
    local hex_col = hex_start + (byte_index + i) * 3
    local byte_str = line:sub(hex_col + 1, hex_col + 2)
    if byte_str:match("^%x%x$") then
      table.insert(bytes, byte_str)
    end
  end

  if #bytes == 0 then
    print("No bytes found under cursor")
    return
  end

  print("Next 8 bytes:", table.concat(bytes, " "))
end

function M.open()
  -- run :%!xxd -g 2
  vim.cmd('%!xxd -g 2')

  -- create a new namespace for your plugin's virtual text
  local ns_id = vim.api.nvim_create_namespace("hex_reader")

  -- get current buffer
  local bufnr = vim.api.nvim_get_current_buf()

  -- add virtual text to each line
  for i = 0, line_count - 1 do
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, i, -1, {
      virt_text = { { "Hello world", "Comment" } },
      virt_text_pos = "eol", -- put it at the end of the line
    })
  end
end

return M
