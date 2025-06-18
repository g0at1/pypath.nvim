local M = {}
function M.init(opts)
	vim.keymap.set("n", opts.key, "<cmd>" .. opts.open_cmd .. "<CR>", { desc = "Open pypath file-manager" })
end
return M
