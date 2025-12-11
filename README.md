# 🔧 Axle.nvim - Keymap Browser Plugin

A clean, organized Neovim plugin to browse, search, and manage your keymaps with a beautiful 3-column interface.

![Axle Demo](https://img.shields.io/badge/Neovim-0.8%2B-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## ✨ Features

- **📋 3-Column Layout**: Clean MODE │ KEYMAPS │ DESCRIPTION format
- **🎯 Config-Only Scanning**: Only scans keymaps from `config/keymaps.lua` (no runtime clutter)
- **🔍 Telescope Integration**: Fuzzy search through keymaps with live filtering
- **➕ Manual Keymap Addition**: Add shortcuts you know with interactive prompts
- **⚠️ Duplicate Detection**: Prevents duplicate keymaps and shows conflicts
- **💾 Persistence**: Save and load your manual keymaps automatically

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "deb-debri3/Axle",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    -- Plugin loads automatically
    -- Keymaps are available immediately
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "deb-debri3/Axle",
  requires = { "nvim-telescope/telescope.nvim" },
  config = function()
    require('axle')
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-telescope/telescope.nvim'
Plug 'deb-debri3/Axle'
```

## 🚀 Usage

### Keymaps

| Key | Description |
|-----|-------------|
| `<leader>mb` | 🔍 Open keymap browser with search |
| `<leader>mbs` | ⚡ Quick keymap search (input prompt) |
| `<leader>mba` | ➕ Add keymap manually (interactive) |
| `<leader>mbd` | ⚠️ Show duplicate keymaps |
| `<leader>mbS` | 💾 Save manual keymaps to file |
| `<leader>mbL` | 📂 Load manual keymaps from file |
| `<leader>mbr` | 🔄 Reload plugin (development) |

### Display Format

```
═══════════════════════════════════════════════════════════════════════════════════════════════════
║                                    🔧 AXLE - KEYMAP BROWSER (20 total)                           ║
═══════════════════════════════════════════════════════════════════════════════════════════════════
│ MODE   │ KEYMAPS                        │ DESCRIPTION                                              │
────────────────────────────────────────────────────────────────────────────────────────────────────
│ N      │ <C-p>                          │ Fuzzy find files                                         │
│ N      │ <leader>bb                     │ Buffers                                                  │
│ I      │ jk                             │ Exit insert mode                                         │
│ N      │ <C-g>                          │ Grep text in project                                     │
═══════════════════════════════════════════════════════════════════════════════════════════════════
```

### Telescope Interface

**Special Keys in Search:**
- `<Enter>` - Show keymap details
- `<C-g>` - Jump to keymap definition in config file
- `<C-a>` - Add current search term as new keymap

## 🛠️ Configuration

Axle works out of the box with no configuration needed. It automatically:

- Scans your `lua/config/keymaps.lua` file
- Sets up all keymaps with `<leader>mb` prefix
- Loads any previously saved manual keymaps

### Custom Configuration

```lua
{
  "deb-debri3/axle.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    local axle = require('axle')
    
    -- Add some manual keymaps (optional)
    local ui = require('axle.ui_core')
    ui.add_keymap("n", "<leader>custom", "My custom keymap")
    ui.add_keymap("i", "<C-x>", "Custom insert mode keymap")
  end,
}
```

## 🎯 Manual Keymaps

Add keymaps you know but aren't in your config:

1. Press `<leader>mba`
2. Enter keymap (e.g., `<leader>ff`)
3. Choose mode (n/i/v/x/t/c/s/o)
4. Enter description

Manual keymaps are automatically saved and loaded on startup.

## ⚠️ Duplicate Prevention

Axle prevents duplicate keymaps with:

- **✅ Real-time validation** - Warns when adding existing keymaps
- **🔍 Duplicate detection** - Use `<leader>mbd` to find conflicts  
- **🔄 Smart overwrite** - Option to overwrite existing manual keymaps
- **📂 Load filtering** - Automatically filters duplicates when loading saved keymaps

When you try to add a keymap that already exists, Axle will:
1. Show a warning with the existing keymap details
2. Offer to overwrite (for manual keymaps only)  
3. Prevent the duplicate from being added

## 📋 Requirements

- **Neovim 0.8+**
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** (recommended, fallback UI available)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for efficient keymap management in Neovim
- Inspired by the need for organized, searchable keymaps
- Uses Telescope.nvim for beautiful fuzzy searching