---@class nvim_relative_date.Config
---Number of milliseconds to wait between the buffer text changed or the window
---was scrolled and the plugin should update the dates in the buffer.
---@field debounce_ms integer?
---Highlight group to use for the inline text
---@field highlight_groups table<string, string>?
---Filetypes to consider enabling this plugin in.
---For each buffer with this filetype, `should_attach_to_buffer` will
---be executed to determine if the plugin should attach to that buffer.
---
---Use `{ "*" }` to consider all filetypes and execute more advanced logic in
---`should_attach_to_buffer`.
---@field filetypes string[]?
---A function that is run for each buffer with the filetype mentioned in
---`filetypes`.
---
---The output of this function determines if the plugin should be
---attached to that buffer.
---@field should_attach_to_buffer (fun(bufnr: integer): boolean) | nil

---@class nvim_relative_date.FullConfig
---@field debounce_ms integer
---@field highlight_groups table<string, string>
---@field filetypes string[]
---@field should_attach_to_buffer fun(bufnr: integer): boolean

---@type nvim_relative_date.FullConfig
local default_config = {
	debounce_ms = 100,
	highlight_groups = {
    early = "DiffAdd",
    late = "DiffRemove",
    today = "DiffChange",
	},
	filetypes = { "markdown" },
	should_attach_to_buffer = function(bufnr)
		return vim.bo[bufnr].buftype == ""
	end,
}

return {
	default = default_config,
}
