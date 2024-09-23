local M = {}

local relative_date = require("nvim_relative_date.relative_date")
local relative_date_common = require("nvim_relative_date.common")

local namespace_id = vim.api.nvim_create_namespace("nvim_relative_date")

local iso_date_pattern = "(%d%d%d%d)%-(%d%d)%-(%d%d)"

-- Name of a buffer-scoped variable, that, when set, means the plugin
-- is attached to that buffer.
local buf_scoped_attached_variable_name = "nvim_relative_date_attached"

---@param bufnr integer
---@param start_line integer 1-based, inclusive
---@param end_line integer 1-based, inclusive
---@param highlight_groups table<string, string> Name of the highlight groups to use
---@param current_osdate osdate
function M.show_relative_dates_in_line_range(bufnr, start_line, end_line, highlight_groups, current_osdate)
	vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, start_line - 1, end_line)

	local visible_buffer_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, true)

	for line_index, line in ipairs(visible_buffer_lines) do
		local match_start_index = 1

		while true do
			-- 1-based, inclusive
			local start_column, end_column, year_str, month_str, day_str =
				line:find(iso_date_pattern, match_start_index)
			if start_column == nil or end_column == nil then
				break
			end

			match_start_index = start_column + 1

			local target_date = os.date("*t", os.time({ year = year_str, month = month_str, day = day_str })) --[[@as osdate]]

			local nextdate = os.time({ year = year_str, month = month_str, day = day_str })
			local curdate = os.time()
			local diff = os.difftime(nextdate, curdate) / (24 * 60 * 60)

			local target_relative_date = relative_date.get_relative_date(current_osdate, target_date)

			local highlight_group
			if target_relative_date == 'today' then
				highlight_group = highlight_groups.today
			elseif diff < 0 then
				highlight_group = highlight_groups.late
			elseif diff > 0 then
				highlight_group = highlight_groups.early
			end

			if target_relative_date ~= nil then
				-- 0-based
				local line_nr = (start_line - 1) + (line_index - 1)
				vim.api.nvim_buf_set_extmark(bufnr, namespace_id, line_nr, end_column, {
					virt_text = {
						{ string.format(" ( %s)", target_relative_date), highlight_group },
					},
					virt_text_pos = "inline",
					right_gravity = false,
				})
			end
		end
	end
end

---@class nvim_relative_date.AttachBufferOpts
---@field bufnr integer
---@field invalidate_buffer fun(bufnr: integer): nil
---@field debounced_invalidate_buffer fun(bufnr: integer): nil

---@param opts nvim_relative_date.AttachBufferOpts
function M.attach(opts)
	vim.b[opts.bufnr][buf_scoped_attached_variable_name] = true
	opts.invalidate_buffer(opts.bufnr)

	-- TODO: use nvim_buf_attach (`on_lines`) to only invalidate the lines that changed
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = relative_date_common.augroup,
		buffer = opts.bufnr,
		callback = function()
			opts.debounced_invalidate_buffer(opts.bufnr)
		end,
	})

	vim.api.nvim_create_autocmd("WinScrolled", {
		group = relative_date_common.augroup,
		buffer = opts.bufnr,
		callback = function()
			-- TODO: update only the region of the window that was scrolled
			opts.debounced_invalidate_buffer(opts.bufnr)
		end,
	})
end

---@param bufnr integer
function M.detach(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
	vim.b[bufnr][buf_scoped_attached_variable_name] = nil

	vim.api.nvim_clear_autocmds({
		group = relative_date_common.augroup,
		buffer = bufnr,
	})
end

---@param bufnr integer
---@return boolean
function M.is_attached(bufnr)
	return vim.b[bufnr][buf_scoped_attached_variable_name] ~= nil
end

return M
