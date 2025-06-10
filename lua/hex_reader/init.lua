local M = {}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {
    -- default options
    show_ascii = true,
    show_address = true,
  }, opts or {})
end

function M.open()
  vim.cmd('%!xxd -g 2')
end

return M
