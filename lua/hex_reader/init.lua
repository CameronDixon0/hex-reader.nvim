local M = {}

local values = {}  -- holds decoded values like values.uint8 and values.int8

--- Converts list of byte strings (e.g. { "01", "ff", ... }) into values
---@param bytes string[]
function M.convert(bytes)
  values = { uint8 = {}, int8 = {} }

  for _, hex in ipairs(bytes) do
    local byte = tonumber(hex, 16)
    table.insert(values.uint8, byte)

    if byte > 127 then
      byte = byte - 256  -- convert to signed int8
    end
    table.insert(values.int8, byte)
  end
end

--- Renders the values table as virtual text on the first line
function M.show()
  local bufnr = vim.api.nvim_get_current_buf()
  local ns_id = vim.api.nvim_create_namespace("hex_reader")

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  if not values.uint8 or #values.uint8 == 0 then
    vim.notify("No values to show", vim.log.levels.WARN)
    return
  end

  local display = string.format("uint8: %s | int8: %s",
    table.concat(values.uint8, " "),
    table.concat(values.int8, " ")
  )

  vim.api.nvim_buf_set_extmark(bufnr, ns_id, 0, -1, {
    virt_text = { { display, "Comment" } },
    virt_text_pos = "eol",
  })
end

--- Reads 8 hex bytes under the cursor and converts/shows them
function M.inspect_bytes()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local line = vim.api.nvim_get_current_line()
  local hex_start = 10
  local byte_index = math.floor((col - hex_start) / 3)

  local bytes = {}

  for i = 0, 7 do
    local hex_col = hex_start + (byte_index + i) * 3
    local byte_str = line:sub(hex_col + 1, hex_col + 2)
    if hex_str:match("^%x%x$") then
      table.insert(bytes, hex_str)
    end
  end

  if #bytes > 0 then
    M.convert(bytes)
    M.show()
  else
    vim.notify("Could not read 8 bytes under cursor", vim.log.levels.WARN)
  end
end

function M.open()
  vim.cmd('%!xxd -g 1')
end

return M
