# Axle User Manual

## Overview
Axle is a Neovim plugin that provides a clean, organized way to browse, search, and manage your keymaps. It automatically scans your configuration and allows you to add custom keymaps with built-in duplicate detection.

## Quick Start

### Installation
Add to your plugin manager (lazy.nvim example):
```lua
{
  "your-username/axle",
  config = function()
    require("axle").setup()
  end
}
```

### Basic Usage
- **Browse keymaps**: `<leader>mbl` - Load and browse all keymaps
- **Quick search**: `<leader>mbs` - Search keymaps by name/description
- **Add keymap**: `<leader>mba` - Add a new keymap interactively

## Key Features

### 1. Keymap Browser
Press `<leader>mbl` to open an interactive browser showing all your keymaps organized by mode and source.

**Navigation:**
- Use arrow keys or `j/k` to navigate
- Press `Enter` to view detailed keymap information
- Press `Esc` or `q` to close

### 2. Quick Search
Press `<leader>mbs` to search keymaps instantly. Type keywords to filter results in real-time.

### 3. Adding Keymaps
Press `<leader>mba` to add a custom keymap:

1. **Enter keymap**: Type the key combination (e.g., `<leader>ff`)
2. **Select mode**: Choose from n/i/v/x/t/c/s/o (default: normal mode)
3. **Add description**: Describe what the keymap does

**Duplicate Protection**: If a keymap already exists, you'll be warned and can choose to:
- Overwrite the existing keymap
- Cancel the operation

### 4. Persistence
- **Save keymaps**: `<leader>mbS` - Save your manual keymaps to file
- **Auto-load**: Manual keymaps are automatically loaded on startup

## Advanced Features

### Keymap Sources
Axle recognizes keymaps from multiple sources:
- **Config file**: Your init.lua/init.vim keymaps
- **Manual**: Keymaps added via Axle
- **Plugins**: Third-party plugin keymaps

### Development Tools
- **Reload plugin**: `<leader>mbr` - Reload Axle and rescan keymaps (useful during development)

### Excluding Keymaps
To exclude certain keymaps from scanning, check the main README.md for configuration options.

## Tips & Tricks

1. **Organization**: Use consistent prefixes (like `<leader>f` for file operations) to keep keymaps organized
2. **Descriptions**: Write clear, descriptive names for your keymaps to make them easier to find
3. **Search**: Use partial matches when searching - "file" will find "Open file", "File browser", etc.
4. **Backup**: Use `<leader>mbS` to save your manual keymaps before making major configuration changes

## Troubleshooting

**Keymaps not showing?**
- Press `<leader>mbr` to reload and rescan
- Check if your keymaps are in supported files

**Duplicate warnings?**
- This is a feature! Axle prevents accidental overwrites
- Choose "Overwrite existing" if you want to replace the keymap

**Search not working?**
- Make sure you have Telescope installed for enhanced search
- Fallback search is available without Telescope

## File Locations
- Manual keymaps are saved to: `~/.local/share/nvim/axle/manual_keymaps.lua`
- Configuration is stored in your Neovim data directory

## Support
For issues or feature requests, check the project repository or documentation.