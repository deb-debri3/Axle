# 🚀 Axle - Feature Recommendations

Based on the current v2.1 implementation, here are recommended features to enhance Axle:

---

## 🎯 Priority 1: High Impact, Easy to Implement

### **1. Edit Manual Keymap** ⭐⭐⭐⭐⭐
**Why:** Users might want to fix typos or update descriptions without deleting and re-adding.

**Implementation:**
- Add `<leader>mbe` → Edit manual keymap
- Select keymap → Edit description/key/mode
- Save changes to storage

**User Value:** Saves time, prevents mistakes

---

### **2. Keymap Help/Info Panel** ⭐⭐⭐⭐⭐
**Why:** Show all Axle keybindings in a quick reference.

**Implementation:**
- Add `<leader>mbh` or `<leader>mb?` → Show help
- Display floating window with all keybindings
- Include examples and tips

**User Value:** Discoverability, learning curve reduction

**Example:**
```
╔════════════════════════════════════════╗
║         Axle Keybindings Help          ║
╠════════════════════════════════════════╣
║ <leader>mbl - Browse all keymaps       ║
║ <leader>mba - Add manual keymap        ║
║ <leader>mbd - Delete manual keymap     ║
║ <leader>mbS - Save manual keymaps      ║
║ <leader>mbr - Rescan & sync            ║
║ <leader>mbs - Quick search             ║
║ <C-d> - Delete (in browser)            ║
║ <C-g> - Go to definition (in browser)  ║
╚════════════════════════════════════════╝
```

---

### **3. Statistics/Info Command** ⭐⭐⭐⭐
**Why:** Users want to know what's tracked.

**Implementation:**
- Add `<leader>mbi` → Show info
- Display: auto count, manual count, total, last sync time
- Show storage file location

**User Value:** Transparency, debugging

**Example:**
```
Axle Statistics:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Auto keymaps:     42
Manual keymaps:   8
Total keymaps:    50
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Last sync:        2026-01-14 11:30:00
Storage:          ~/.local/share/nvim/axle/keymaps.json
```

---

### **4. Export/Backup Keymaps** ⭐⭐⭐⭐
**Why:** Users want to backup or share their manual keymaps.

**Implementation:**
- Add `<leader>mbx` → Export manual keymaps
- Save to: `~/axle-backup-YYYYMMDD.json`
- Optional: Export to markdown format

**User Value:** Safety, portability, sharing

---

### **5. Import Keymaps** ⭐⭐⭐⭐
**Why:** Restore from backup or import from others.

**Implementation:**
- Add `<leader>mbm` → Import manual keymaps
- Select file → Merge with existing
- Check for duplicates

**User Value:** Recovery, collaboration

---

## 🎨 Priority 2: Enhanced User Experience

### **6. Search by Category** ⭐⭐⭐⭐
**Why:** Filter view by auto/manual.

**Implementation:**
- In browser: `<C-f>` → Filter by category
- Options: All / Auto only / Manual only / Unsaved only

**User Value:** Focus, organization

---

### **7. Favorite/Star Keymaps** ⭐⭐⭐⭐
**Why:** Mark frequently used keymaps.

**Implementation:**
- In browser: `<C-s>` → Toggle star
- Display: ⭐ indicator
- Filter view to show favorites only

**User Value:** Quick access, personalization

---

### **8. Sort Options** ⭐⭐⭐
**Why:** Different sorting preferences.

**Implementation:**
- In browser: `<C-o>` → Sort options
- Options: Mode, Key, Description, Category, Frequency

**User Value:** Organization, findability

---

### **9. Keymap Usage Statistics** ⭐⭐⭐⭐⭐
**Why:** Know which keymaps you actually use.

**Implementation:**
- Track keymap execution count
- Show usage count in browser
- Highlight most/least used

**User Value:** Optimization, cleanup decisions

**Example:**
```
N      <leader>ff       Find files           [auto] (used 45×)
N      <leader>old      Old unused           [manual] (used 0×)
```

---

### **10. Duplicate Detection Across Files** ⭐⭐⭐
**Why:** Prevent conflicts.

**Implementation:**
- Scan runtime keymaps
- Show conflicts/overlaps
- Suggest resolutions

**User Value:** Conflict prevention

---

## 🔧 Priority 3: Power User Features

### **11. Keymap Groups/Tags** ⭐⭐⭐⭐
**Why:** Organize keymaps by project/plugin/purpose.

**Implementation:**
- Add tags: `#git`, `#lsp`, `#navigation`
- Filter by tag
- Bulk operations by tag

**User Value:** Organization, context switching

---

### **12. Keymap Suggestions** ⭐⭐⭐⭐⭐
**Why:** Discover unused keys.

**Implementation:**
- Analyze available key combinations
- Suggest unused `<leader>*` keys
- Check for plugin conflicts

**User Value:** Optimization, discovery

---

### **13. Vim Command Integration** ⭐⭐⭐
**Why:** Traditional command-line interface.

**Implementation:**
- `:Axle` → Open browser
- `:AxleAdd` → Add keymap
- `:AxleDelete` → Delete keymap
- `:AxleInfo` → Show statistics
- `:AxleSync` → Rescan & sync

**User Value:** Alternative interface, scripting

---

### **14. Telescope Actions** ⭐⭐⭐⭐
**Why:** More actions in browser.

**Implementation:**
- `<C-e>` → Edit manual keymap
- `<C-c>` → Copy keymap to clipboard
- `<C-x>` → Export selected keymap
- `<C-t>` → Add tag

**User Value:** Efficiency, power

---

### **15. Health Check** ⭐⭐⭐⭐
**Why:** Validate configuration.

**Implementation:**
- `:checkhealth axle`
- Check: storage file, duplicates, conflicts
- Suggest fixes

**User Value:** Troubleshooting, maintenance

---

## 🌟 Priority 4: Advanced Features

### **16. Keymap History** ⭐⭐⭐
**Why:** Track changes over time.

**Implementation:**
- Keep history of manual keymap changes
- Show diff view
- Undo/redo changes

**User Value:** Safety net, auditing

---

### **17. Plugin Keymap Detection** ⭐⭐⭐⭐
**Why:** Track which plugins added which keymaps.

**Implementation:**
- Detect plugin source
- Label: `[auto] (telescope.nvim)`
- Group by plugin

**User Value:** Organization, debugging

---

### **18. Keymap Conflicts Resolver** ⭐⭐⭐⭐⭐
**Why:** Handle overlapping keymaps.

**Implementation:**
- Detect conflicts
- Show interactive resolver
- Choose which to keep

**User Value:** Clean configuration

---

### **19. Learning Mode** ⭐⭐⭐⭐
**Why:** Help users learn keymaps.

**Implementation:**
- Show popup hints for available keymaps
- Quiz mode: practice keymaps
- Track learning progress

**User Value:** Education, retention

---

### **20. Multi-file Configuration Support** ⭐⭐⭐
**Why:** Some users split keymaps across files.

**Implementation:**
- Scan multiple keymap files
- Label by file source
- Manage separately

**User Value:** Flexibility

---

## 📊 Recommended Implementation Order

### **Phase 1: Core Enhancements (v2.2)**
1. ✅ Edit manual keymap (`<leader>mbe`)
2. ✅ Help panel (`<leader>mbh`)
3. ✅ Statistics info (`<leader>mbi`)
4. ✅ Export/Import (`<leader>mbx` / `<leader>mbm`)

**Time:** 1-2 days
**Impact:** High
**Complexity:** Low

---

### **Phase 2: UX Improvements (v2.3)**
5. ✅ Search by category (filter)
6. ✅ Sort options
7. ✅ Vim commands (`:Axle`, etc.)
8. ✅ Health check

**Time:** 2-3 days
**Impact:** High
**Complexity:** Medium

---

### **Phase 3: Advanced Features (v2.4)**
9. ✅ Usage statistics
10. ✅ Favorite/star keymaps
11. ✅ Keymap suggestions
12. ✅ Telescope actions

**Time:** 3-4 days
**Impact:** Medium-High
**Complexity:** Medium-High

---

### **Phase 4: Power Features (v3.0)**
13. ✅ Keymap groups/tags
14. ✅ Conflict resolver
15. ✅ Plugin detection
16. ✅ Learning mode

**Time:** 1-2 weeks
**Impact:** High (for power users)
**Complexity:** High

---

## 💡 Quick Wins (Implement First)

### **Top 5 Easiest + High Impact:**

1. **Help Panel** (`<leader>mbh`) → 30 min
2. **Statistics Info** (`<leader>mbi`) → 20 min
3. **Edit Manual Keymap** (`<leader>mbe`) → 1 hour
4. **Export Keymaps** (`<leader>mbx`) → 30 min
5. **Vim Commands** (`:Axle`) → 1 hour

**Total Time:** ~3.5 hours
**Total Impact:** 🚀🚀🚀🚀🚀

---

## ❓ Which Features Interest You Most?

### **Developer Focus:**
- Edit, Export/Import, Commands
- Health check, Conflict detection

### **Casual User Focus:**
- Help panel, Statistics
- Search/Filter, Sort

### **Power User Focus:**
- Usage statistics, Tags/Groups
- Favorites, Suggestions

### **All Users:**
- Help panel (everyone needs this!)
- Edit keymap (common use case)
- Statistics (transparency)

---

## 🎯 My Top 3 Recommendations

### **#1: Help Panel** (`<leader>mbh`)
**Why:** Every user needs to discover what keybindings exist.
**Effort:** Low (30 min)
**Impact:** Very High

### **#2: Edit Manual Keymap** (`<leader>mbe`)
**Why:** Common need, prevents delete+re-add workflow.
**Effort:** Medium (1 hour)
**Impact:** High

### **#3: Statistics/Info** (`<leader>mbi`)
**Why:** Transparency builds trust, helps debugging.
**Effort:** Low (20 min)
**Impact:** Medium-High

---

## 🤔 Questions for You

1. **What's your use case?**
   - Personal? Team? Plugin development?

2. **What annoys you most?**
   - Missing features? Workflows? UI?

3. **What would make Axle indispensable?**
   - One killer feature that makes it a must-have?

4. **Who is your target user?**
   - Beginners? Power users? Both?

---

## 📝 Implementation Template

For any feature, we can follow this structure:

```lua
-- 1. Add function to storage.lua (if needed)
-- 2. Add function to ui_core.lua
-- 3. Add keybinding to init.lua
-- 4. Update README.md
-- 5. Test workflow
-- 6. Document in feature guide
```

---

**Status:** 💡 RECOMMENDATIONS READY
**Next Step:** Pick 1-3 features to implement
**Version:** 2.1 → 2.2

**Let me know which features interest you most!** 🚀
