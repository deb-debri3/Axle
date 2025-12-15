# 🔧 Axle.nvim - Keymap Browser Plugin

A clean Neovim plugin to browse, search, and manage your keymaps with a beautiful 3-column interface.

![Axle Demo](https://img.shields.io/badge/Neovim-0.8%2B-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## ✨ Features

- **🎯 Smart Keymap Scanning**: Automatically finds keymaps in common locations or custom paths
- **🔍 Telescope Integration**: Fuzzy search through keymaps with live filtering
- **➕ Manual Keymap Addition**: Add shortcuts you know with interactive prompts

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

## 🚀 Usage

### Keymaps

| Key | Description |
|-----|-------------|
| `<leader>mbs` | 🔍 Quick search keymaps |
| `<leader>mba` | ➕ Add keymap manually (interactive) |
| `<leader>mbS` | 💾 Save manual keymaps to file |
| `<leader>mbl` | 📂 Load manual keymaps from file + browse |
| `<leader>mbr` | 🔄 Reload plugin (development) |

### 📝 Excluding Keymaps from Scanning

To exclude specific keymaps from being scanned by Axle, simply comment them out by adding -- at the beginning of the line. Note that multi-line comments will not work properly.

```lua
-- This keymap will NOT appear in Axle
-- keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })

-- This keymap WILL appear in Axle  
keymap.set("n", "<leader>gg", builtin.live_grep, { desc = "Live grep" })
```

**Note:** After commenting/uncommenting keymaps, use `<leader>mbr` to reload and rescan your configuration.

## 🛠️ Configuration

Axle works out of the box with no configuration needed. It automatically:

- Scans common keymap file locations (see below)
- Sets up all keymaps with `<leader>mb` prefix
- Loads any previously saved manual keymaps

### 📁 Keymap File Detection

Axle automatically scans these common locations for keymap files:

- `lua/config/keymaps.lua` (LazyVim style)
- `lua/keymaps.lua` (common convention)
- `lua/core/keymaps.lua` (NvChad style)
- `lua/mappings.lua`
- `lua/keys.lua`
- `init.lua` (main config file)

### 🎛️ Custom Configuration

You can specify custom keymap file paths:

```lua
{
  "deb-debri3/Axle",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require('axle').setup({
      keymap_paths = {
        "lua/my-keymaps.lua",           -- Relative to config dir
        "lua/custom/mappings.lua",      -- Multiple files supported
        "/absolute/path/to/keys.lua"    -- Absolute paths also work
      }
    })
  end,
}
```

**Note:** If `keymap_paths` is provided, only those files will be scanned (default locations are ignored).


### 💾 Manual Keymap Storage

Manual keymaps added with `<leader>mba` are stored in:

```
~/.local/share/nvim/axle/manual_keymaps.lua
```

**Storage Workflow:**
- `<leader>mba` → Add keymap → **Stored in memory** (temporary)
- `<leader>mbS` → Save keymaps → **Stored to file** (persistent) 
- `<leader>mbl` → Load keymaps → **Load from file + browse**

**Source Labels:**
- **manual** - Keymaps added via `<leader>mba` or loaded from manual_keymaps.lua
- **default** - Keymaps scanned from your config files (keymaps.lua, runtime)

**File follows XDG standards:**
- `~/.config/nvim/` - Configuration files (init.lua, keymaps.lua)
- `~/.local/share/nvim/` - User data files (manual keymaps, plugin data)


## 🎯 Manual Keymaps

Add keymaps you know but aren't in your config:

1. Press `<leader>mba`
2. Enter keymap (e.g., `<leader>ff`)
3. Choose mode (n/i/v/x/t/c/s/o)
4. Enter description

Manual keymaps are automatically saved and loaded on startup.

## 📋 Requirements

- **Neovim 0.8+**
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** (recommended, fallback UI available)

## 🤝 Contributing

Contributions are welcome!  
If you’d like to improve Axle, feel free to open a Pull Request.

For major changes or questions or improvement, you can contact me at:  
📧 **debrajkhadka0859@gmail.com**

Please make sure your contributions follow the project's style and remain compatible with the GPLv3 license.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)**.  
See the [LICENSE](LICENSE) file for full details.

You are free to use, modify, and distribute this project, as long as any derivative works remain **open source under the same license**.

## 🙏 Acknowledgments

- Built for efficient keymap management in Neovim
- Inspired by the need for organized, searchable keymaps
- Uses Telescope.nvim for beautiful fuzzy searching
