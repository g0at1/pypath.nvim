local M = {}

function M.open(opts)
	opts = opts or {}
	local base_cmd = opts.cmd or M.opts.cmd or "pypath"
	if vim.fn.executable(base_cmd) == 0 then
		vim.notify(
			string.format("Command '%s' not installed.\nPlease visit https://github.com/g0at/pypath", base_cmd),
			vim.log.levels.WARN
		)
		return
	end
	local cmd = "PYPATH_MODE=neovim " .. base_cmd

	local cols, lines = vim.o.columns, vim.o.lines
	local width = math.floor(cols * 0.8)
	local height = math.floor(lines * 0.8)
	local row = math.floor((lines - height) / 2)
	local col = math.floor((cols - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	})

	vim.fn.termopen(cmd, {
		on_exit = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end

			local cache = vim.fn.expand("~/.pypath_last")
			if vim.fn.filereadable(cache) == 1 then
				local lines = vim.fn.readfile(cache)
				vim.fn.delete(cache)

				local file = lines[1] or ""
				file = file:gsub("\r", ""):gsub("\n", ""):gsub("^%s+", ""):gsub("%s+$", "")

				if #file > 0 then
					vim.cmd("edit " .. vim.fn.fnameescape(file))
				end
			end
		end,
	})

	vim.api.nvim_set_current_win(win)
	vim.cmd("startinsert")
end

local keymaps = require("pypath.keymaps")
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", {
		cmd = "pypath",
		open_cmd = "Pypath",
		key = "<leader>pp",
	}, opts or {})

	vim.api.nvim_create_user_command(M.opts.open_cmd, function()
		M.open()
	end, { nargs = 0 })

	keymaps.init(M.opts)
end

return M
