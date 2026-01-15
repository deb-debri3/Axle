# ⚡ Axle v2.0 - Quick Start Guide

## 🎯 5-Minute Overview

### **What Changed?**
- **Before:** 2 files (internal + additional) 😕
- **After:** 1 file (auto + manual) 😊

### **New Storage:**
```
~/.local/share/nvim/axle/keymaps.json
{
  "auto": [...],    ← From keymaps.lua (auto-synced)
  "manual": [...]   ← Added by you
}
```

---

## 🚀 Quick Test (5 steps)

### **Step 1: Browse Keymaps**
```vim
Press: <leader>mbl
Result: See all keymaps with [auto] or [manual] labels
```

### **Step 2: Add Manual Keymap**
```vim
Press: <leader>mba
Enter: <leader>test
Mode: n
Description: Test keymap
Result: Added to memory
```

### **Step 3: Save Manual Keymap**
```vim
Press: <leader>mbS
Result: Saved to keymaps.json
```

### **Step 4: Edit Your Config**
```vim
# Open keymaps.lua
# Add: vim.keymap.set("n", "<leader>new", "...", { desc = "New keymap" })
# Save file
```

### **Step 5: Rescan & Sync** ⭐
```vim
Press: <leader>mbr
Result: "Total: 51 | New: 1 | Updated: 0"
Press: <leader>mbl
Result: See new keymap with [auto] label
```

✅ **Success!** Your new keymap was automatically detected and synced!

---

## 📋 All Keybindings

| Key | What It Does |
|-----|--------------|
| `<leader>mbl` | Browse all keymaps (auto + manual) |
| `<leader>mba` | Add manual keymap |
| `<leader>mbe` | Edit manual keymap ⭐ NEW |
| `<leader>mbd` | Delete manual keymap (interactive) |
| `<leader>mbh` | Show help panel ⭐ NEW |
| `<leader>mbi` | Show statistics/info ⭐ NEW |
| `<leader>mbS` | Save manual keymaps |
| `<leader>mbr` | Rescan & sync auto keymaps |
| `<leader>mbs` | Quick search |
| `<C-d>` | Delete (in browser, normal mode) |

### Vim Commands ⭐ NEW

| Command | What It Does |
|---------|--------------|
| `:Axle` | Browse all keymaps |
| `:AxleAdd` | Add manual keymap |
| `:AxleEdit` | Edit manual keymap |
| `:AxleDelete` | Delete manual keymap |
| `:AxleInfo` | Show statistics |
| `:AxleSync` | Rescan & sync |
| `:AxleHelp` | Show help panel |

---

## 🎨 What You'll See

### **Before (Old System)**
```
MODE   KEY              DESCRIPTION           SOURCE
N      <leader>ff       Find files           default
N      <leader>xx       Custom action        additional
```

### **After (New System)**
```
MODE   KEY              DESCRIPTION           CATEGORY
N      <leader>ff       Find files           [auto]
N      <leader>xx       Custom action        [manual]
N      <leader>yy       Unsaved              [manual (unsaved)]
```

---

## 🔄 Common Workflows

### **Daily Usage**
```
<leader>mbl → Search → Use keymap
```

### **Add Custom Keymap**
```
<leader>mba → Fill details → <leader>mbS
```

### **Remove Manual Keymap**
```
Method 1: <leader>mbd → Select → Confirm
Method 2: <leader>mbl → Navigate (normal mode) → <C-d> → Confirm
```

### **After Editing Config**
```
Edit keymaps.lua → <leader>mbr → <leader>mbl
```

---

## 🐛 Troubleshooting

### **Problem: Plugin not loading**
```bash
# Check if file exists
ls ~/.config/nvim/lua/axle/

# Reload Neovim
:qa
nvim
```

### **Problem: Keymaps not showing**
```vim
" Check storage file
:echo stdpath("data") . "/axle/keymaps.json"

" Rescan
<leader>mbr
```

### **Problem: Manual keymaps lost**
```vim
" Did you save them?
<leader>mbS

" Check file
:e ~/.local/share/nvim/axle/keymaps.json
```

---

## 📊 What Files Changed?

```
✨ NEW:  lua/axle/storage.lua
🔧 EDIT: lua/axle/ui_core.lua
🔧 EDIT: lua/axle/init.lua
📖 EDIT: README.md
```

---

## ✅ Testing Checklist

Quick checklist before committing:

- [ ] Plugin loads without errors
- [ ] `<leader>mbl` shows keymaps
- [ ] `<leader>mba` adds keymap
- [ ] `<leader>mbS` saves keymap
- [ ] `<leader>mbr` rescans
- [ ] New keymaps detected
- [ ] Updated descriptions detected
- [ ] Category labels show correctly

---

## 🎉 Ready to Deploy?

### **Option 1: Test First (Recommended)**
```bash
# Test in Neovim
nvim ~/.config/nvim/lua/config/keymaps.lua

# Try all keybindings
# Verify everything works
```

### **Option 2: Deploy Immediately**
```bash
# Stage and commit
git add lua/axle/*.lua README.md
git commit -m "feat: refactor to single-file storage (v2.0)"

# Push
git push origin main

# Tag release
git tag v2.0.0
git push origin v2.0.0
```

---

## 📚 More Info

- **Full Guide:** `IMPLEMENTATION_GUIDE.md`
- **Architecture:** `ARCHITECTURE.md`
- **Changelog:** `CHANGELOG_V2.md`
- **Review:** `REVIEW_AND_CONFIRM.md`

---

## 🎊 That's It!

You now have a **simpler, clearer, auto-syncing** keymap browser!

**Key Feature:** Press `<leader>mbr` after editing config → Automatic sync!

**Questions?** Check the documentation or ask!

---

**Version:** 2.0.0  
**Status:** ✅ READY  
**Time to Test:** 5 minutes  
**Difficulty:** Easy
