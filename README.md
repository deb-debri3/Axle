# 🔧 Axle.nvim - Keymap Browser Plugin

A clean Neovim plugin to browse, search, and manage your keymaps with a beautiful 3-column interface.

![Axle Demo](https://img.shields.io/badge/Neovim-0.8%2B-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## ✨ Features

- **🎯 Config-Only Scanning**: Only scans keymaps from `config/keymaps.lua` (no runtime clutter)
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

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-telescope/telescope.nvim'
Plug 'deb-debri3/Axle'
```

## 🚀 Usage

### Keymaps

| Key | Description |
|-----|-------------|
| `<leader>mbs` | 🔍 Quick search keymaps |
| `<leader>mba` | ➕ Add keymap manually (interactive) |
| `<leader>mbS` | 💾 Save manual keymaps to file |
| `<leader>mbl` | 📂 Load manual keymaps from file + browse |
| `<leader>mbd` | 🔍 Show duplicate keymaps |
| `<leader>mbr` | 🔄 Reload plugin (development) |

### 📝 Excluding Keymaps from Scanning

To exclude specific keymaps from being scanned by Axle, simply **comment them out** with `--` at the beginning of the line:

```lua
-- This keymap will NOT appear in Axle
-- keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })

-- This keymap WILL appear in Axle  
keymap.set("n", "<leader>gg", builtin.live_grep, { desc = "Live grep" })
```

**Note:** After commenting/uncommenting keymaps, use `<leader>mbr` to reload and rescan your configuration.

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

### 🔗 Version Control Integration

If you want to version control your manual keymaps across machines, create a symlink:

```bash
# Move file to your dotfiles/nvim config
mv ~/.local/share/nvim/axle/manual_keymaps.lua ~/.config/nvim/manual_keymaps.lua

# Create symlink back to original location
mkdir -p ~/.local/share/nvim/axle
ln -s ~/.config/nvim/manual_keymaps.lua ~/.local/share/nvim/axle/manual_keymaps.lua
```

This allows you to:
- Keep manual keymaps in your git-tracked nvim config
- Share keymaps across different machines
- Backup manual keymaps with your dotfiles

## 🎯 Manual Keymaps

Add keymaps you know but aren't in your config:

1. Press `<leader>mba`
2. Enter keymap (e.g., `<leader>ff`)
3. Choose mode (n/i/v/x/t/c/s/o)
4. Enter description

Manual keymaps are automatically saved and loaded on startup.

## ⚠️ Duplicate Prevention

When you try to add a keymap that already exists, Axle will:
1. Show a warning with the existing keymap details
2. Offer to overwrite (for manual keymaps only)  
3. Prevent the duplicate from being added

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
