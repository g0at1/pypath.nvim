local M = {}

function M.open(opts)
  opts = opts or {}
  local cmd = opts.cmd or M.opts.cmd or 'pypath'

  local cols = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(cols * 0.8)
  local height = math.floor(lines * 0.8)
  local row = math.floor((lines - height) / 2)
  local col = math.floor((cols - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'single',
  })

  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end)
    end,
  })

  vim.api.nvim_set_current_win(win)
  vim.cmd('startinsert')
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', {
    cmd = 'pypath',      -- default command
    key = '<leader>pp',  -- default keybinding
    open_cmd = 'Pypath',  -- default user command name
  }, opts or {})

  vim.api.nvim_create_user_command(M.opts.open_cmd, function()
    M.open({ cmd = M.opts.cmd })
  end, {})

  vim.keymap.set('n', M.opts.key, function()
    M.open({ cmd = M.opts.cmd })
  end, { desc = 'Open pypath file manager' })
end

return M
