# 🔧 Troubleshooting

## Keymaps Not Showing Up

If your keymaps aren't being detected by Axle, here are common causes and solutions:

### 1. **Keymap File Location**

**Problem**: Your keymaps are in a different location than the defaults.

**Default locations checked:**
- `lua/config/keymaps.lua` (LazyVim style)
- `lua/keymaps.lua` (common convention) 
- `lua/core/keymaps.lua` (NvChad style)
- `lua/mappings.lua`
- `lua/keys.lua`
- `init.lua`

**Solution**: Either move your keymaps to one of these locations, or specify custom paths in your configuration:

```lua
require('axle').setup({
  keymap_paths = {
    "lua/my-custom-keymaps.lua",
    "lua/another-file.lua"
  }
})
```

### 2. **Keymap Format**

**Problem**: Your keymaps use a format that Axle doesn't recognize.

**Supported formats:**
```lua
-- ✅ Standard format with description
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })

-- ✅ Command format
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- ✅ Function format  
vim.keymap.set("n", "<leader>gg", function()
  -- some code
end, { desc = "Custom function" })

-- ❌ No description (will be ignored)
vim.keymap.set("n", "<leader>x", some_function)

-- ❌ Old style (not supported)
vim.api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<CR>", {})
```

**Solution**: Ensure your keymaps have `desc` fields and use `vim.keymap.set()`.

### 3. **Commented Out Keymaps**

**Problem**: Keymaps are commented out.

```lua
-- This won't be detected
-- vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
```

**Solution**: Remove the `--` comment markers to make keymaps visible to Axle.

### 4. **File Permissions**

**Problem**: Neovim can't read your keymap files.

**Solution**: Check file permissions:
```bash
ls -la ~/.config/nvim/lua/keymaps.lua
```

### 5. **Plugin Loading Issues**

**Problem**: Axle isn't loading properly.

**Debugging steps:**
1. Check plugin installation: `:Lazy` (for lazy.nvim users)
2. Reload plugin: `<leader>mbr`
3. Check for errors: `:messages`

**Manual reload:**
```vim
:lua package.loaded["axle"] = nil
:lua require("axle")
```

### 6. **Neovim Version**

**Problem**: Using Neovim < 0.8

**Solution**: Update Neovim to 0.8 or newer.

### 7. **Telescope Dependency**

**Problem**: Telescope.nvim not installed.

**Solution**: Install telescope.nvim:
```lua
-- In your plugin manager
{ "nvim-telescope/telescope.nvim" }
```

## Getting Help

If none of these solutions work:

1. Enable debug mode and check what files are being scanned:
   ```lua
   -- Temporary debug: Add this to your config
   print("Config path:", vim.fn.stdpath("config"))
   ```

2. Use `<leader>mbr` to reload and rescan

3. Check `:messages` for any error messages

4. Open an issue with:
   - Your Neovim version (`:version`)
   - Your keymap file location and a sample
   - Any error messages from `:messages`

---

**Quick Test**: Try `<leader>mbl` to load the browser - if it opens but shows no keymaps, it's a scanning issue. If it doesn't open at all, it's a plugin loading issue.