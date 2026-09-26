local function insert_header()
  local filename = vim.fn.expand("%:t")
  local date = os.date("%Y-%m-%d")

  local header = {
    "/*=============================================================================",
    "Title: " .. filename,
    "Description: ",
    "Author: Gonza Vizard",
    "Date: " .. date,
    "=============================================================================*/",
  }

  local row = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, header)
end

vim.api.nvim_create_user_command("Header", function(opts)
  if opts.args == "sql" then
    insert_header()
  else
    print("Header no soportado para: " .. opts.args)
  end
end, {
  nargs = 1,
  complete = function()
    return { "sql" }
  end,
})
