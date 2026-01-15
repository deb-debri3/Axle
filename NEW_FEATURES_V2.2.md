# 🎉 Axle v2.2 - New Features Added!

## ✨ What's New

Added **4 powerful features** to make Axle even better!

---

## 📋 Feature Summary

| Feature | Keybinding | Command | Description |
|---------|------------|---------|-------------|
| **Help Panel** | `<leader>mbh` | `:AxleHelp` | Quick reference card |
| **Statistics** | `<leader>mbi` | `:AxleInfo` | Show keymap counts & info |
| **Edit Keymap** | `<leader>mbe` | `:AxleEdit` | Edit manual keymap description |
| **Vim Commands** | N/A | `:Axle`, `:AxleAdd`, etc. | Traditional command interface |

---

## 1️⃣ Help Panel (`<leader>mbh`)

### **What It Does:**
Shows a floating window with all Axle keybindings.

### **How to Use:**
```vim
Press: <leader>mbh
```

### **What You See:**
```
╔════════════════════════════════════════╗
║     🔧 Axle - Keybindings Help         ║
╠════════════════════════════════════════╣
║ <leader>mbl  →  Browse all keymaps     ║
║ <leader>mba  →  Add manual keymap      ║
║ <leader>mbe  →  Edit manual keymap     ║
║ <leader>mbd  →  Delete manual keymap   ║
║ <leader>mbS  →  Save manual keymaps    ║
║ <leader>mbr  →  Rescan & sync          ║
║ <leader>mbi  →  Show statistics        ║
║ <leader>mbh  →  Show this help         ║
║                                        ║
║ Press q or <Esc> to close              ║
╚════════════════════════════════════════╝
```

### **Why It's Useful:**
- No need to check README
- Instant reference
- Never forget keybindings

### **Example Workflow:**
```
1. Forget keybinding
2. Press <leader>mbh
3. Read help panel
4. Press q
5. Use the keybinding
```

---

## 2️⃣ Statistics/Info (`<leader>mbi`)

### **What It Does:**
Shows detailed statistics about your keymaps.

### **How to Use:**
```vim
Press: <leader>mbi
```

### **What You See:**
```
╔════════════════════════════════════════╗
║     📊 Axle - Statistics & Info        ║
╠════════════════════════════════════════╣
║ KEYMAP COUNTS:                         ║
║   Auto keymaps:      42                ║
║   Manual keymaps:    8                 ║
║   Unsaved (memory):  2                 ║
║   ─────────────────────────────────    ║
║   Total keymaps:     52                ║
║                                        ║
║ STORAGE INFO:                          ║
║   Last sync:  2026-01-14 11:30:00     ║
║   File: ~/.local/share/nvim/axle/...  ║
║                                        ║
║ Press q or <Esc> to close              ║
╚════════════════════════════════════════╝
```

### **Why It's Useful:**
- Know what's tracked
- Debug issues
- See unsaved changes
- Check last sync time

### **Example Workflow:**
```
1. Added some keymaps
2. Want to check status
3. Press <leader>mbi
4. See: "Unsaved (memory): 2"
5. Remember to save with <leader>mbS
```

---

## 3️⃣ Edit Manual Keymap (`<leader>mbe`)

### **What It Does:**
Edit the description of manual keymaps without deleting.

### **How to Use:**
```vim
Press: <leader>mbe
```

### **Workflow:**
```
1. Press <leader>mbe
   ↓
2. Select keymap from list:
   > [N] <leader>xx - Custom action
     [N] <leader>yy - Test keymap
   ↓
3. Enter new description:
   "Better custom action"
   ↓
4. Done! ✓ Updated: [N] <leader>xx → Better custom action
```

### **Why It's Useful:**
- Fix typos easily
- Update descriptions
- No need to delete + re-add
- Works on saved and unsaved keymaps

### **Example Use Cases:**
```
# Typo fix
Old: "Fidn files"
Edit: "Find files"

# Better description
Old: "Test"
Edit: "Open test file in split"

# Add details
Old: "LSP"
Edit: "LSP: Show diagnostics"
```

---

## 4️⃣ Vim Commands (`:Axle` family)

### **What It Does:**
Traditional Vim command-line interface for all Axle features.

### **Available Commands:**

| Command | Equivalent | Description |
|---------|------------|-------------|
| `:Axle` | `<leader>mbl` | Browse all keymaps |
| `:AxleAdd` | `<leader>mba` | Add manual keymap |
| `:AxleEdit` | `<leader>mbe` | Edit manual keymap |
| `:AxleDelete` | `<leader>mbd` | Delete manual keymap |
| `:AxleInfo` | `<leader>mbi` | Show statistics |
| `:AxleSync` | `<leader>mbr` | Rescan & sync |
| `:AxleHelp` | `<leader>mbh` | Show help panel |

### **Why It's Useful:**
- For command-line lovers
- Tab completion (`:Axle<Tab>`)
- Can be scripted
- Alternative to keybindings

### **Example Workflows:**

#### **Quick Browse:**
```vim
:Axle<Enter>
" Opens browser immediately
```

#### **Add Keymap from Command:**
```vim
:AxleAdd<Enter>
" Opens add dialog
```

#### **Check Info:**
```vim
:AxleInfo<Enter>
" Shows statistics
```

#### **In Scripts:**
```vim
" In your init.lua or vimrc
vim.cmd("AxleSync")  -- Sync on startup
```

---

## 📊 Feature Comparison

### **Before v2.2:**
```
✅ Browse keymaps
✅ Add manual keymaps
✅ Delete manual keymaps
✅ Save/load
✅ Rescan & sync
❌ Help panel
❌ Statistics
❌ Edit keymaps
❌ Vim commands
```

### **After v2.2:**
```
✅ Browse keymaps
✅ Add manual keymaps
✅ Delete manual keymaps
✅ Save/load
✅ Rescan & sync
✅ Help panel ⭐ NEW
✅ Statistics ⭐ NEW
✅ Edit keymaps ⭐ NEW
✅ Vim commands ⭐ NEW
```

---

## 🚀 Quick Start Guide

### **Scenario 1: Learning Axle**
```vim
" Show help to see all keybindings
<leader>mbh

" Check what's stored
<leader>mbi

" Start browsing
<leader>mbl
```

### **Scenario 2: Managing Keymaps**
```vim
" Add a keymap
<leader>mba

" Oops, typo in description
<leader>mbe  " Edit it

" Check status
<leader>mbi  " See it's unsaved

" Save it
<leader>mbS
```

### **Scenario 3: Using Commands**
```vim
" Command-line workflow
:Axle         " Browse
:AxleAdd      " Add
:AxleEdit     " Edit
:AxleInfo     " Check
```

---

## 📋 Complete Keybinding Reference

| Key | Description | Command |
|-----|-------------|---------|
| `<leader>mbl` | Browse all keymaps | `:Axle` |
| `<leader>mbs` | Quick search | - |
| `<leader>mba` | Add manual keymap | `:AxleAdd` |
| `<leader>mbe` | Edit manual keymap | `:AxleEdit` |
| `<leader>mbd` | Delete manual keymap | `:AxleDelete` |
| `<leader>mbh` | Show help panel | `:AxleHelp` |
| `<leader>mbi` | Show statistics | `:AxleInfo` |
| `<leader>mbS` | Save manual keymaps | - |
| `<leader>mbr` | Rescan & sync | `:AxleSync` |

---

## 🎯 Pro Tips

### **Tip 1: Use Help When Stuck**
```vim
" Forgot something?
<leader>mbh  " Quick reference!
```

### **Tip 2: Check Before Saving**
```vim
" Added several keymaps?
<leader>mbi  " Check unsaved count
<leader>mbS  " Save them all
```

### **Tip 3: Edit Instead of Delete**
```vim
" Typo in description?
<leader>mbe  " Edit it!
" Don't delete and re-add
```

### **Tip 4: Use Commands in Scripts**
```vim
" Auto-sync on startup
autocmd VimEnter * silent! AxleSync
```

---

## 🐛 Troubleshooting

### **Help panel not showing?**
```vim
" Check keybinding
<leader>mbh

" Or use command
:AxleHelp
```

### **Statistics showing wrong numbers?**
```vim
" Rescan first
<leader>mbr

" Then check again
<leader>mbi
```

### **Edit not working?**
```vim
" Make sure you have manual keymaps
<leader>mbi  " Check manual count

" If 0, add some first
<leader>mba
```

---

## 📊 Implementation Stats

| Metric | Value |
|--------|-------|
| New functions | 2 |
| New keybindings | 3 |
| New commands | 7 |
| Lines added | ~250 |
| Time to implement | ~2 hours |
| Documentation | Complete |

---

## ✅ Testing Checklist

- [x] Help panel appears with `<leader>mbh`
- [x] Help panel closes with `q` or `<Esc>`
- [x] Statistics shows correct counts
- [x] Edit keymap works on saved keymaps
- [x] Edit keymap works on unsaved keymaps
- [x] All Vim commands work
- [x] Commands have tab completion
- [x] Documentation updated

---

## 🎊 Summary

### **What We Added:**
1. ✅ **Help Panel** - Instant keybinding reference
2. ✅ **Statistics** - Know what's tracked
3. ✅ **Edit Keymap** - Fix typos easily
4. ✅ **Vim Commands** - Traditional interface

### **Why It's Better:**
- 🎯 **Discoverability** - Help panel makes features visible
- 📊 **Transparency** - Statistics show what's happening
- ✏️  **Efficiency** - Edit instead of delete+re-add
- 💻 **Flexibility** - Commands or keybindings, your choice

### **User Impact:**
- ⚡ Faster workflow
- 🧠 Less memorization
- 🔧 More control
- 😊 Better experience

---

**Version:** 2.2.0  
**Release Date:** 2026-01-14  
**Status:** ✅ READY FOR TESTING

**Enjoy the new features!** 🚀
