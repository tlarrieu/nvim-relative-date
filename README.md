# nvim-relative-date

Display relative dates as inline virtual text

## Demo

Default behavior:

![ISO dates are rendered like usual in the document.](https://github.com/Gelio/nvim-relative-date/assets/889383/237c36c0-9b3b-4e32-b632-1343b3b24b31)

With nvim-relative-date:

![Next to ISO dates within a week from now, there is a label like "(today)" rendered using virtual inline text.](https://github.com/Gelio/nvim-relative-date/assets/889383/ebbf5038-3519-4364-b47d-b7894d9bfbb4)

## Detected relative dates

- today, yesterday, tomorrow
- days of last week, this week, next week

## Installation

- Using [lazy.nvim](https://github.com/folke/lazy.nvim):

  ```lua
  {
      "Gelio/nvim-relative-date",
      config = true,
      ft = "markdown",
      cmd = { "RelativeDateAttach", "RelativeDateToggle" },
  }
  ```

- Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

  ```lua
  use {
      "Gelio/nvim-relative-date",
      config = function()
           require("nvim_relative_date").setup()
      end,
      ft = "markdown",
      cmd = { "RelativeDateAttach", "RelativeDateToggle" },
  }
  ```

## Configuration (optional)

By default, the plugin will attach to all Markdown buffers and show relative
dates as inline virtual text using the `Comment` highlight group.

The `setup()` method accepts the following configuration options:

- `debounce_ms` (`string`) - number of milliseconds to wait between the buffer
  text changed or the window was scrolled and the plugin should update the dates
  in the buffer.

  Default: `100`

- `highlight_groups` (`table<string, string>`) - highlight group to use for the inline text

  Default: `{ early = "DiffAdd", late = "DiffRemove", today = "DiffChange" }`

- `filetypes` (`string[]`) - filetypes to consider enabling this plugin in. For
  each buffer with this filetype, `should_attach_to_buffer` will be executed to
  determine if the plugin attach to it.

  Use `{ "*" }` to consider all filetypes and execute more advanced logic in
  `should_attach_to_buffer`.

  Default: `{ "markdown" }`

- `should_attach_to_buffer` - a function that is run for each buffer with the
  filetype mentioned in `filetypes`. The output of this function determines if
  the plugin should attach to that buffer.

  Default: accepts all normal buffers

## Commands

nvim-relative-date exposes the following Ex commands:

- `RelativeDateAttach` - attaches the plugin to the current buffer (even if the
  buffer wouldn't be attached to given the current configuration).

- `RelativeDateDetach` - detaches the plugin from the current buffer.

- `RelativeDateToggle` - works like `RelativeDateAttach` or `RelativeDateDetach`
  depending on whether the current buffer is attached to or not.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Recommended plugins

nvim-relative-date works well with:

- [cmp-natdat](https://github.com/Gelio/cmp-natdat) - a
  [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source for expanding relative
  dates into ISO dates.
