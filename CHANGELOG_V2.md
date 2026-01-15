# Axle v2.0 - Simplified Storage Refactoring

## 🎯 Overview
Complete refactoring to a simplified single-file storage system with clear "auto" and "manual" categories.

## ✨ What Changed

### **New Architecture**

**Before (v1.x):**
- Two files: `axle-internal-keymaps.lua` + `axle-additional-keymaps.lua`
- Complex persistence layer
- Confusing terminology (internal/additional)
- Manual keymaps not showing properly

**After (v2.0):**
- **Single file**: `keymaps.json`
- **Two categories**: `auto` (from keymaps.lua) + `manual` (user-added)
- Simple storage module
- Clear, consistent display

---

## 📂 New File Structure

```
~/.local/share/nvim/axle/
└── keymaps.json              # Single source of truth
    {
      "auto": [...],          # Auto-scanned from keymaps.lua
      "manual": [...],        # User manually added
      "last_sync": "..."      # Timestamp
    }
```

---

## 🔄 New Workflows

### **Plugin Load (First Time)**
1. Scans `keymaps.lua` → Extract all keymaps
2. Creates `keymaps.json` with auto category
3. Displays notification with count

### **Plugin Load (Subsequent)**
1. Scans `keymaps.lua` → Current keymaps
2. Loads `keymaps.json` → Saved state
3. **Compares & syncs** new/updated keymaps
4. Updates auto category automatically

### **`<leader>mbr` - Reload & Rescan**
1. Rescans `keymaps.lua` completely
2. Compares with stored auto keymaps
3. **Detects new/updated keymaps**
4. Updates local DB (keymaps.json)
5. Shows summary: Total | New | Updated

### **`<leader>mbl` - Browse Keymaps**
- Displays merged view: auto + manual
- Clear category labels: `[auto]` or `[manual]`
- Searchable via Telescope

### **`<leader>mba` - Add Manual Keymap**
- Add keymap interactively
- Duplicate checking (both auto & manual)
- Stored in memory until saved

### **`<leader>mbS` - Save Manual Keymaps**
- Persists manual keymaps to `keymaps.json`
- Clears memory after save
- Shows confirmation

---

## 🆕 New Files

### **`lua/axle/storage.lua`**
Core storage module with functions:
- `load()` - Load keymaps.json
- `save(data)` - Save to keymaps.json
- `sync_auto_keymaps(scanned)` - Compare & update auto
- `add_manual_keymap()` - Add single manual keymap
- `save_manual_keymaps()` - Save all manual keymaps
- `get_all_keymaps()` - Get merged view
- `keymap_exists()` - Check duplicates
- `migrate_from_old_system()` - Migration helper

---

## 🔧 Modified Files

### **`lua/axle/ui_core.lua`**
- Changed: `persistence` → `storage` module
- Changed: `M.additional_keymaps` → `M.manual_keymaps`
- Changed: All `source` references → `category`
- Added: `M.rescan_and_update()` - Rescan logic
- Fixed: Duplicate checking logic
- Fixed: Display format with category labels
- Simplified: Single merged keymaps list

### **`lua/axle/init.lua`**
- Updated: All keymap descriptions
- Changed: `<leader>mbr` now calls `rescan_and_update()`
- Changed: `<leader>mbl` now just shows (no load step)
- Simplified: Removed separate load keymap binding

---

## 🎨 Display Changes

### **Old Format:**
```
MODE   KEY              DESCRIPTION           SOURCE
N      <leader>ff       Find files           default
N      <leader>xx       Custom action        additional
```

### **New Format:**
```
MODE   KEY              DESCRIPTION           CATEGORY
N      <leader>ff       Find files           [auto]
N      <leader>xx       Custom action        [manual]
N      <leader>yy       Unsaved keymap       [manual (unsaved)]
```

---

## 🔄 Migration

The plugin **automatically migrates** from old storage formats:
- `axle-internal-keymaps.lua` → `auto` category
- `axle-additional-keymaps.lua` → `manual` category
- `manual_keymaps.lua` → `manual` category

Old files are backed up with `.backup` extension.

---

## ✅ Benefits

✅ **Simpler** - One file, one source of truth  
✅ **Clearer** - auto vs manual categories easy to understand  
✅ **Automatic** - Auto-sync on reload with change detection  
✅ **Reliable** - No duplicate tracking issues  
✅ **Persistent** - Survives Neovim restarts  
✅ **Faster** - JSON format for quick read/write  
✅ **Maintainable** - Less code, easier to debug  

---

## 🐛 Bugs Fixed

- ❌ Manual keymaps not displaying properly
- ❌ Reference to undefined `M.manual_keymaps` (lines 361, 370, 374)
- ❌ Duplicate keymaps from multiple sources
- ❌ Confusing source/category terminology
- ❌ Complex two-file sync logic

---

## 📋 API Changes

### **Removed Functions:**
- `persistence.initialize()`
- `persistence.sync_new_keymaps()`
- `persistence.get_all_keymaps()`
- `M.save_additional_keymaps()`
- `M.load_additional_keymaps()`

### **New Functions:**
- `storage.load()`
- `storage.save(data)`
- `storage.sync_auto_keymaps(scanned)`
- `storage.get_all_keymaps()`
- `storage.keymap_exists(mode, key)`
- `M.save_manual_keymaps()`
- `M.rescan_and_update()`

### **Terminology Changes:**
- `internal` → `auto`
- `additional` → `manual`
- `source` → `category`

---

## 🧪 Testing Checklist

- [ ] First install creates keymaps.json
- [ ] Auto keymaps sync correctly
- [ ] Manual keymaps save and load
- [ ] `<leader>mbr` detects new keymaps
- [ ] `<leader>mbr` detects updated keymaps
- [ ] `<leader>mbl` shows merged view
- [ ] Duplicate detection works
- [ ] Category labels display correctly
- [ ] Migration from old format works
- [ ] Telescope integration works
- [ ] Simple UI fallback works

---

## 📝 Next Steps

1. Test in real Neovim environment
2. Verify migration works correctly
3. Update README.md with new workflows
4. Update USER_MANUAL.md
5. Remove old `persistence.lua` file
6. Update TROUBLESHOOTING.md
7. Tag release v2.0

---

## 📅 Release Date
2026-01-14
