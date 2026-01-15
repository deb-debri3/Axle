# 🗑️ Axle - Remove Keymaps Feature Guide

## 🎯 Overview

Added user-friendly keymap removal feature with multiple methods!

---

## ✨ Features

### **What Can Be Removed?**
- ✅ **Manual keymaps** (saved) - From storage
- ✅ **Manual keymaps** (unsaved) - From memory
- ❌ **Auto keymaps** - Cannot be removed (edit keymaps.lua instead)

### **Why This Design?**
- **Auto keymaps** come from your config → edit the source
- **Manual keymaps** are user-added → can be removed anytime

---

## 🚀 How to Remove Keymaps

### **Method 1: Dedicated Remove Command** (Recommended)

```vim
Press: <leader>mbd
```

**Flow:**
1. Shows list of all manual keymaps (saved + unsaved)
2. Select keymap to remove
3. Confirm deletion
4. Keymap removed immediately

**Example:**
```
Select manual keymap to remove:
> [N] <leader>xx - Custom action
  [N] <leader>yy - Test keymap (unsaved)
  [I] <C-s> - Quick save

→ Select one
→ Confirm: "Yes, delete it"
→ ✓ Deleted: [N] <leader>xx
```

---

### **Method 2: Remove from Browser** (Quick)

```vim
Press: <leader>mbl    (Browse keymaps)
Navigate to manual keymap (normal mode)
Press: <C-d>          (Delete)
```

**Flow:**
1. Browse keymaps with `<leader>mbl`
2. Find manual keymap (labeled `[manual]` or `[manual (unsaved)]`)
3. Press `<C-d>` in **normal mode** (or insert mode for convenience)
4. Confirm deletion
5. Returns to browser (keymap gone)

**If you try to delete auto keymap:**
```
⚠️ Cannot delete auto keymaps.
Edit your keymaps.lua file instead.
```

---

## 🎨 User Experience

### **Confirmation Dialog**
Always asks for confirmation to prevent accidents:

```
Delete keymap?
[N] <leader>xx → Custom action

> Yes, delete it
  No, cancel
```

### **Success Notification**
```
✓ Deleted: [N] <leader>xx
```

### **Error Handling**
```
# No manual keymaps
⚠️ No manual keymaps to remove

# Trying to delete auto keymap
⚠️ Cannot delete auto keymaps.
Edit your keymaps.lua file instead.
```

---

## 📋 Complete Workflow Examples

### **Example 1: Testing a Keymap**

```vim
# 1. Add test keymap
<leader>mba
Enter: <leader>test
Mode: n
Desc: Testing keymap

# 2. Test it (maybe it doesn't work)
<leader>test

# 3. Remove it
<leader>mbd
Select: [N] <leader>test - Testing keymap (unsaved)
Confirm: Yes, delete it
Result: ✓ Deleted unsaved: [N] <leader>test
```

---

### **Example 2: Cleaning Up Old Keymaps**

```vim
# 1. Browse to see all keymaps
<leader>mbl

# 2. Find old manual keymap
Navigate to: [N] <leader>old - Old unused keymap [manual]

# 3. Quick delete with <C-d>
<C-d>
Confirm: Yes, delete it
Result: ✓ Deleted: [N] <leader>old

# 4. Continues browsing (keymap removed)
```

---

### **Example 3: Bulk Cleanup**

```vim
# 1. Use dedicated remove command
<leader>mbd

# 2. Remove first keymap
Select: [N] <leader>old1 - Old keymap
Confirm: Yes
Result: ✓ Deleted

# 3. Remove another
<leader>mbd
Select: [N] <leader>old2 - Another old
Confirm: Yes
Result: ✓ Deleted

# Repeat until clean
```

---

## 🔧 Technical Details

### **storage.lua - New Function**

```lua
-- Remove manual keymap
function M.remove_manual_keymap(mode, key)
	local storage = M.load()
	local removed = false
	
	for i, km in ipairs(storage.manual) do
		if km.mode == mode and km.key == key then
			table.remove(storage.manual, i)
			removed = true
			break
		end
	end
	
	if removed then
		M.save(storage)
	end
	
	return removed
end
```

### **ui_core.lua - New Function**

```lua
-- Remove manual keymap interactively
function M.remove_keymap_interactive()
	-- Get all manual keymaps (saved + unsaved)
	-- Show selection UI
	-- Confirm deletion
	-- Remove from storage or memory
end
```

### **Telescope Integration**

```lua
-- In show() function, added <C-d> mapping
map("i", "<C-d>", function()
	-- Check if manual keymap
	-- Show confirmation
	-- Delete from storage or memory
	-- Show notification
end)
```

---

## 🎯 Key Bindings

| Key | Location | Action |
|-----|----------|--------|
| `<leader>mbd` | Anywhere | Open remove dialog |
| `<C-d>` | In Telescope browser (normal or insert mode) | Delete selected manual keymap |

---

## ⚠️ Important Notes

### **What Happens to Unsaved Keymaps?**
- Removed from memory immediately
- Gone until you add them again
- No undo (confirmation required)

### **What Happens to Saved Keymaps?**
- Removed from `keymaps.json` immediately
- Persists after restart
- Cannot be undone (confirmation required)

### **Backup Recommendation**
Before bulk cleanup:
```bash
# Backup your keymaps
cp ~/.local/share/nvim/axle/keymaps.json \
   ~/.local/share/nvim/axle/keymaps.backup.json
```

---

## 🧪 Testing Checklist

- [ ] Add manual keymap
- [ ] Remove with `<leader>mbd` (unsaved)
- [ ] Verify it's gone
- [ ] Add and save manual keymap
- [ ] Remove with `<leader>mbd` (saved)
- [ ] Restart Neovim → verify still gone
- [ ] Try removing auto keymap → should warn
- [ ] Remove from browser with `<C-d>`
- [ ] Test canceling deletion
- [ ] Test with no manual keymaps

---

## 🎨 UI Screenshots (Text)

### **Remove Dialog**
```
╔════════════════════════════════════════╗
║ Select manual keymap to remove:       ║
╠════════════════════════════════════════╣
║ > [N] <leader>xx - Custom action      ║
║   [N] <leader>yy - Test (unsaved)     ║
║   [I] <C-s> - Quick save              ║
╚════════════════════════════════════════╝
```

### **Confirmation**
```
╔════════════════════════════════════════╗
║ Delete keymap?                         ║
║ [N] <leader>xx → Custom action        ║
╠════════════════════════════════════════╣
║ > Yes, delete it                       ║
║   No, cancel                           ║
╚════════════════════════════════════════╝
```

### **Success**
```
✓ Deleted: [N] <leader>xx
```

---

## 💡 Pro Tips

1. **Test Before Committing:** Add keymap → test → remove if bad
2. **Use <C-d> in Browser:** Quick deletion while browsing
3. **Bulk Cleanup:** Use `<leader>mbd` repeatedly for multiple removals
4. **Backup First:** Backup keymaps.json before major cleanup
5. **Auto Keymaps:** Edit source file, then `<leader>mbr` to sync

---

## 🚀 Summary

### **What We Added:**
- ✅ `storage.remove_manual_keymap()` function
- ✅ `ui_core.remove_keymap_interactive()` function
- ✅ `<leader>mbd` keybinding
- ✅ `<C-d>` in Telescope browser
- ✅ Confirmation dialogs
- ✅ Smart category checking
- ✅ Memory + storage support

### **Why It's User-Friendly:**
- 🎯 Two methods (dedicated + in-browser)
- ✅ Confirmation required (prevents accidents)
- 🚫 Cannot delete auto keymaps (protects config)
- 📋 Shows saved vs unsaved status
- 💬 Clear notifications
- 🔒 Safe and reliable

---

**Feature Status:** ✅ COMPLETE  
**Version:** 2.1  
**Date:** 2026-01-14
