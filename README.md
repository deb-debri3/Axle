# 🔧 Axle.nvim - Keymap Browser Plugin

A clean Neovim plugin to browse, search, and manage your keymaps with a beautiful 3-column interface.

![Axle Demo](https://img.shields.io/badge/Neovim-0.8%2B-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## ✨ Features

- **🎯 Smart Keymap Scanning**: Automatically finds keymaps in common locations or custom paths
- **🔍 Telescope Integration**: Fuzzy search through keymaps with live filtering
- **➕ Manual Keymap Addition**: Add shortcuts you know with interactive prompts
- **💾 Reliable Persistence**: Automatic baseline tracking and sync of keymaps across sessions

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
| `<leader>mbl` | 📂 Browse all keymaps (auto + manual) |
| `<leader>mbs` | 🔍 Quick search keymaps |
| `<leader>mba` | ➕ Add manual keymap (interactive) |
| `<leader>mbe` | ✏️  Edit manual keymap (interactive) |
| `<leader>mbd` | 🗑️  Delete manual keymap (interactive) |
| `<leader>mbh` | ❓ Show help panel |
| `<leader>mbi` | 📊 Show statistics/info |
| `<leader>mbx` | 📤 Export manual keymaps |
| `<leader>mbm` | 📥 Import manual keymaps |
| `<leader>mbS` | 💾 Save manual keymaps to storage |
| `<leader>mbr` | 🔄 Reload & rescan (sync auto keymaps) |

### Vim Commands

| Command | Description |
|---------|-------------|
| `:Axle` | Browse all keymaps |
| `:AxleAdd` | Add manual keymap |
| `:AxleEdit` | Edit manual keymap |
| `:AxleDelete` | Delete manual keymap |
| `:AxleInfo` | Show statistics |
| `:AxleExport` | Export manual keymaps |
| `:AxleImport` | Import manual keymaps |
| `:AxleSync` | Rescan & sync |
| `:AxleHelp` | Show help panel |

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


### 💾 Keymap Storage System

Axle uses a simple single-file system to track your keymaps with two categories:

#### 📂 Storage File

```
~/.local/share/nvim/axle/
└── keymaps.json     # Single source of truth
    {
      "auto": [...],    # Auto-scanned from keymaps.lua
      "manual": [...],  # User manually added
      "last_sync": "2026-01-14T11:10:00"
    }
```

#### 🔄 How It Works

**On First Install:**
1. Scans all keymaps from your `keymaps.lua` (or custom paths)
2. Creates `keymaps.json` with auto category
3. Ready to use immediately

**On Subsequent Loads:**
1. Loads existing `keymaps.json`
2. Displays merged view (auto + manual keymaps)

**When You Press `<leader>mbr` (Reload & Rescan):**
1. Rescans your `keymaps.lua` completely
2. Compares with stored auto keymaps
3. **Automatically detects and syncs**:
   - New keymaps added to your config
   - Updated keymap descriptions
4. Shows summary: Total | New | Updated

**Storage Workflow:**
- `<leader>mba` → Add manual keymap → **Stored in memory** (temporary)
- `<leader>mbS` → Save keymaps → **Persisted to keymaps.json** (permanent)
- `<leader>mbl` → Browse → **Shows auto + manual** (merged view)
- `<leader>mbr` → Rescan → **Syncs auto keymaps** from config

**Category Labels:**
- **`[auto]`** - Keymaps from your config files (auto-synced)
- **`[manual]`** - Keymaps you manually added via `<leader>mba`
- **`[manual (unsaved)]`** - Manual keymaps not yet saved

**Benefits:**
- ✅ Single file, simple structure
- ✅ Automatic sync when you modify config
- ✅ Clear separation between auto and manual
- ✅ Reliable state across Neovim restarts
- ✅ Smart duplicate detection


## 🎯 Manual Keymaps

Add keymaps you know but aren't in your config:

1. Press `<leader>mba` (or `:AxleAdd`)
2. Enter keymap (e.g., `<leader>ff`)
3. Choose mode (n/i/v/x/t/c/s/o)
4. Enter description
5. Press `<leader>mbS` to save permanently

**Edit manual keymaps:**
- Press `<leader>mbe` (or `:AxleEdit`)
- Select keymap from list
- Enter new description
- Changes saved automatically

**Remove manual keymaps:**
- **Option 1:** Press `<leader>mbd` (or `:AxleDelete`) → Select from list → Confirm deletion
- **Option 2:** In Telescope browser (`<leader>mbl`), press `<C-d>` in normal mode

**Note:** Auto keymaps cannot be deleted through Axle. Edit your `keymaps.lua` file instead.

Manual keymaps are labeled `[manual]` in the browser and persist across Neovim restarts after saving.

## 📊 Help & Info

**Need help?**
- Press `<leader>mbh` (or `:AxleHelp`) → Shows all keybindings in a floating window
- Quick reference without leaving Neovim!

**Check statistics:**
- Press `<leader>mbi` (or `:AxleInfo`) → Shows:
  - Auto keymap count
  - Manual keymap count
  - Unsaved keymaps in memory
  - Last sync time
  - Storage file location

## 📤📥 Export & Import

**Export manual keymaps:**
- Press `<leader>mbx` (or `:AxleExport`)
- Creates backup file: `~/axle-backup-YYYYMMDD-HHMMSS.json`
- Contains all your manual keymaps

**Import manual keymaps:**
- Press `<leader>mbm` (or `:AxleImport`)
- Select backup file
- Imports and merges with existing keymaps
- Skips duplicates automatically

**Use cases:**
- Backup before major changes
- Share keymaps with teammates
- Move between machines
- Disaster recovery

## ⭐ Favorites

**Star your most-used keymaps:**
- In browser (`<leader>mbl`), press `<C-s>` to toggle star
- Starred keymaps show with ⭐ icon
- Quick visual identification of important keymaps

**Display example:**
```
⭐ N  <leader>ff  Find files     [auto]
   N  <leader>fg  Live grep      [auto]
⭐ N  <leader>xx  My favorite    [manual]
```

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
