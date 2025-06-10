# hex-reader.nvim

A Neovim plugin for interactively reading and interpreting bytes in hex dumps. It displays the value under the cursor as various integer and floating-point types, making it easy to inspect binary data directly in your editor.

## Features

- View 8 bytes under the cursor and see their interpretation as:
  - Unsigned and signed integers (8, 16, 24, 32, 64 bits)
  - IEEE 754 floating-point numbers (float32, float64)
- Displays values as virtual text alongside the hex dump
- Easy toggling between hex and normal view
- Written in pure Lua, with FFI for float/double conversion

## Installation

Use your favorite plugin manager. For example, with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'camerondixon/hex-reader.nvim',
  config = function()
    require('hex_reader').setup()
  end
}
```

Or with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'camerondixon/hex-reader.nvim',
  config = function()
    require('hex_reader').setup()
  end
}
```

## Usage

1. Open a binary file in Neovim.
2. Run `:lua require('hex_reader').open()` to view the file as a hex dump.
3. Move the cursor over any byte. The plugin will display the interpretation of the next 8 bytes as various types in virtual text.
4. To return to normal view, run `:lua require('hex_reader').close()`.

### Example

![hex-reader.nvim demo](https://raw.githubusercontent.com/camerondixon/hex-reader.nvim/main/demo.gif)

## API

- `require('hex_reader').setup()` — Sets up autocommands for interactive display.
- `require('hex_reader').open()` — Converts the current buffer to hex mode (using `xxd`).
- `require('hex_reader').close()` — Converts the buffer back to normal mode.

## Requirements

- Neovim 0.7+
- [xxd](https://linux.die.net/man/1/xxd) (should be available on most systems)
- LuaJIT (for FFI float/double conversion)