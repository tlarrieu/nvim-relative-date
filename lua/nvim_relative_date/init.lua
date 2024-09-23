local M = {}

local timers = require("nvim_relative_date.timers")
local relative_date_buffer = require("nvim_relative_date.buffer")
local relative_date_common = require("nvim_relative_date.common")

---@type nvim_relative_date.FullConfig
local current_config = nil

---@param winid integer
---@return integer, integer
local function get_visible_window_lines_range(winid)
	return vim.fn.line("w0", winid), vim.fn.line("w$", winid)
end

---@param bufnr integer
local function show_relative_dates(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	if not relative_date_buffer.is_attached(bufnr) then
		return
	end

	local buf_winids = vim.fn.win_findbuf(bufnr)
	if #buf_winids == 0 then
		return
	end

	local current_osdate = os.date("*t") --[[@as osdate]]

	for _, winid in ipairs(buf_winids) do
		-- 1-based, inclusive
		local start_line, end_line = get_visible_window_lines_range(winid)

		relative_date_buffer.show_relative_dates_in_line_range(
			bufnr,
			start_line,
			end_line,
			current_config.highlight_groups,
			current_osdate
		)
	end
end

---@type table<integer, (fun(bufid: integer): nil) | nil>
local debounced_update_buffer_map = {}

---@param bufid integer
local function debounced_show_relative_dates(bufid)
	local debounced_update_buffer = debounced_update_buffer_map[bufid]
	if debounced_update_buffer == nil then
		debounced_update_buffer = timers.debounce(show_relative_dates, current_config.debounce_ms)
		debounced_update_buffer_map[bufid] = debounced_update_buffer
	end

	debounced_update_buffer(bufid)
end

local function detach_all_buffers()
	vim.api.nvim_clear_autocmds({ group = relative_date_common.augroup })

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and relative_date_buffer.is_attached(bufnr) then
			relative_date_buffer.detach(bufnr)
		end
	end
end

local function create_user_commands()
	vim.api.nvim_create_user_command("RelativeDateAttach", function()
		M.attach_buffer(vim.api.nvim_get_current_buf())
	end, { desc = "Attach nvim-relative-date to the current buffer" })

	vim.api.nvim_create_user_command("RelativeDateDetach", function()
		M.detach_buffer(vim.api.nvim_get_current_buf())
	end, { desc = "Detach nvim-relative-date to the current buffer" })

	vim.api.nvim_create_user_command("RelativeDateToggle", function()
		M.toggle_buffer(vim.api.nvim_get_current_buf())
	end, { desc = "Toggle nvim-relative-date in the current buffer" })
end

---@param config nvim_relative_date.Config?
function M.setup(config)
	if current_config ~= nil then
		detach_all_buffers()
	end

	current_config = vim.tbl_extend("force", require("nvim_relative_date.config").default, config or {})

	vim.api.nvim_create_autocmd("FileType", {
		group = relative_date_common.augroup,
		pattern = vim.fn.join(current_config.filetypes, ","),
		callback = function(opt)
			local bufnr = opt.buf

			if current_config.should_attach_to_buffer(bufnr) then
				M.attach_buffer(bufnr)
			end
		end,
	})

	create_user_commands()
end

---@param bufnr integer
function M.attach_buffer(bufnr)
	relative_date_buffer.attach({
		bufnr = bufnr,
		debounced_invalidate_buffer = debounced_show_relative_dates,
		invalidate_buffer = show_relative_dates,
	})
end

---@param bufnr integer
function M.detach_buffer(bufnr)
	relative_date_buffer.detach(bufnr)
end

---@param bufnr integer
function M.toggle_buffer(bufnr)
	if relative_date_buffer.is_attached(bufnr) then
		M.detach_buffer(bufnr)
	else
		M.attach_buffer(bufnr)
	end
end

return M
