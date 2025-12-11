# 🚀 Quick Installation Guide

## For Lazy.nvim Users (Recommended)

Add this to your `lua/plugins/` directory or in your plugin config:

```lua
{
  "deb-debri3/axle.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    -- Plugin auto-loads with default settings
    -- All keymaps available immediately with <leader>mb prefix
  end,
}
```

## Manual Setup (Optional)

```lua
{
  "deb-debri3/axle.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require('axle').setup({
      add_examples = true,  -- Add example keymaps
    })
    
    -- Add your own manual keymaps
    local ui = require('axle.ui_core')
    ui.add_keymap("n", "<leader>custom", "My custom keymap")
  end,
}
```

## Usage

- `<leader>mb` - Browse all keymaps
- `<leader>mba` - Add new keymap
- `<leader>mbs` - Quick search
- `<leader>mbd` - Show duplicates

That's it! 🎉