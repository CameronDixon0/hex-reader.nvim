local M = {}

local last_bytes = {}

local values = {}

function M.read_next_8_bytes()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local line = vim.api.nvim_get_current_line()
  local hex_start = 10
  local byte_index = math.floor((col - hex_start) / 3)

  last_bytes = {}

  for i = 0, 7 do
    local hex_col = hex_start + (byte_index + i) * 3
    local byte_str = line:sub(hex_col + 1, hex_col + 2)
    if byte_str:match("^%x%x$") then
      table.insert(last_bytes, byte_str) -- keep as string for now
    end
  end

  if #last_bytes == 0 then
    vim.notify("No bytes found under cursor", vim.log.levels.WARN)
  end
end

function M.convert(bytes)
  local byte = tonumber(last_bytes[1], 16)
  values = {
    uint8 = byte,
    int8 = byte > 127 and byte - 256 or byte,
  }
end

function M.show()
  local ns_id = vim.api.nvim_create_namespace("hex_reader")
  local bufnr = vim.api.nvim_get_current_buf()

  M.read_next_8_bytes()
  M.convert()

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  vim.api.nvim_buf_set_extmark(bufnr, ns_id, 0, -1, {
    virt_text = { { string.format("uint8: %s", values.uint8), "Comment" } },
    virt_text_pos = "eol", -- put it at the end of the line
  })
end

function M.open()
  vim.cmd('%!xxd -g 1')
end

return M
