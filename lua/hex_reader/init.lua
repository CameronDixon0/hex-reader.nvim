local M = {}

local last_bytes = {}
local values = {}

local isOpen = false

function M.setup()
  vim.api.nvim_create_augroup("HexReaderCursor", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = "HexReaderCursor",
    pattern = "*",
    callback = function()
      require("hex_reader").show()
    end,
  })
end
-- Read 8 bytes under cursor
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
      table.insert(last_bytes, byte_str)
    else
      table.insert(last_bytes, "00") -- pad missing bytes with 0
    end
  end

  if #last_bytes == 0 then
    vim.notify("No bytes found under cursor", vim.log.levels.WARN)
  end
end

-- Convert hex byte strings to integer
local function bytes_to_int(bytes, signed)
  local val = 0
  for i = 1, #bytes do
    val = val + tonumber(bytes[i], 16) * (256 ^ (i - 1))
  end

  if signed then
    local bits = #bytes * 8
    local max_unsigned = 2 ^ bits
    local max_signed = 2 ^ (bits - 1)
    if val >= max_signed then
      return val - max_unsigned
    end
  end

  return val
end

local ffi = require("ffi")

function M.convert()
  local function to_bytes(bytes)
    return string.char(unpack(vim.tbl_map(function(b)
      return tonumber(b, 16)
    end, bytes)))
  end

  local float32, float64

  if #last_bytes >= 4 then
    local str4 = to_bytes({ unpack(last_bytes, 1, 4) })
    ffi.cdef[[
      typedef union { float f; uint8_t b[4]; } FloatUnion;
    ]]
    local fu = ffi.new("FloatUnion")
    ffi.copy(fu.b, str4, 4)
    float32 = fu.f
  end

  if #last_bytes >= 8 then
    local str8 = to_bytes({ unpack(last_bytes, 1, 8) })
    ffi.cdef[[
      typedef union { double d; uint8_t b[8]; } DoubleUnion;
    ]]
    local du = ffi.new("DoubleUnion")
    ffi.copy(du.b, str8, 8)
    float64 = du.d
  end

  values = {
    uint8  = bytes_to_int({ last_bytes[1] }, false),
    int8   = bytes_to_int({ last_bytes[1] }, true),
    uint16 = bytes_to_int({ last_bytes[1], last_bytes[2] }, false),
    int16  = bytes_to_int({ last_bytes[1], last_bytes[2] }, true),
    uint24 = bytes_to_int({ last_bytes[1], last_bytes[2], last_bytes[3] }, false),
    int24  = bytes_to_int({ last_bytes[1], last_bytes[2], last_bytes[3] }, true),
    uint32 = bytes_to_int({ last_bytes[1], last_bytes[2], last_bytes[3], last_bytes[4] }, false),
    int32  = bytes_to_int({ last_bytes[1], last_bytes[2], last_bytes[3], last_bytes[4] }, true),
    uint64 = bytes_to_int({ unpack(last_bytes, 1, 8) }, false),
    int64  = bytes_to_int({ unpack(last_bytes, 1, 8) }, true),
    float32 = float32,
    float64 = float64,
  }
end

-- Display values as virtual text
function M.show()
  if not isOpen then return
  local ns_id = vim.api.nvim_create_namespace("hex_reader")
  local bufnr = vim.api.nvim_get_current_buf()

  M.read_next_8_bytes()
  M.convert()

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local display_keys = {
    "uint8", "int8", "uint16", "int16", "uint24", "int24",
    "uint32", "int32", "uint64", "int64", "float32", "float64"
  }

  for i, key in ipairs(display_keys) do
    local value = values[key]
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, -1, {
      virt_text = { { string.format("%s: %s", key, value), "Comment" } },
      virt_text_pos = "eol",
    })
  end
end

-- Open in hex mode
function M.open()
  vim.cmd('%!xxd -g 1')
  isOpen = true
end

return M
