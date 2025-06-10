local M = {}

M.say_hello = function()
  print("Hello from my plugin!")
end

-- You can also define autocommands, keymaps, etc. here
-- vim.api.nvim_create_user_command('SayHello', M.say_hello, {})

return M
