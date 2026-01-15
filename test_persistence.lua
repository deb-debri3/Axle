-- Test script for Axle persistence system
-- Run with: nvim --headless -c "luafile test_persistence.lua" -c "qa"

print("=== Axle Persistence System Test ===\n")

-- Mock vim.fn.stdpath to use a test directory
local test_dir = "/tmp/axle-test"
os.execute("rm -rf " .. test_dir)
os.execute("mkdir -p " .. test_dir)

local original_stdpath = vim.fn.stdpath
vim.fn.stdpath = function(what)
	if what == "data" then
		return test_dir
	end
	return original_stdpath(what)
end

-- Mock vim.notify
local notifications = {}
vim.notify = function(msg, level, opts)
	table.insert(notifications, {msg = msg, level = level, opts = opts})
	print("NOTIFY: " .. msg)
end

-- Load the persistence module
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"
local persistence = require("axle.persistence")

print("\n1. Testing first install detection...")
assert(persistence.is_first_install() == true, "Should detect first install")
print("✓ First install detected correctly")

print("\n2. Creating test keymaps...")
local test_keymaps = {
	{mode = "n", key = "<leader>ff", description = "Find files", source = "config"},
	{mode = "n", key = "<leader>gg", description = "Live grep", source = "config"},
	{mode = "i", key = "<C-s>", description = "Save file", source = "config"},
}

print("\n3. Initializing (first time)...")
persistence.initialize(test_keymaps)
assert(persistence.is_first_install() == false, "Should not be first install anymore")
print("✓ Internal keymaps file created")

print("\n4. Loading internal keymaps...")
local loaded = persistence.load_internal_keymaps()
assert(#loaded == 3, "Should load 3 keymaps")
print("✓ Loaded " .. #loaded .. " internal keymaps")

print("\n5. Adding new keymaps to config...")
local new_keymaps = {
	{mode = "n", key = "<leader>ff", description = "Find files", source = "config"},
	{mode = "n", key = "<leader>gg", description = "Live grep", source = "config"},
	{mode = "i", key = "<C-s>", description = "Save file", source = "config"},
	{mode = "n", key = "<leader>bb", description = "Buffer list", source = "config"},
	{mode = "n", key = "<leader>tt", description = "Terminal", source = "config"},
}

print("\n6. Syncing new keymaps...")
persistence.sync_new_keymaps(new_keymaps)
local synced = persistence.load_internal_keymaps()
assert(#synced == 5, "Should have 5 keymaps after sync")
print("✓ Synced successfully, now have " .. #synced .. " keymaps")

print("\n7. Testing additional keymaps...")
local additional = {
	{mode = "n", key = "<leader>xx", description = "Custom action"},
	{mode = "v", key = "<leader>yy", description = "Visual custom"},
}
local file = persistence.save_additional_keymaps(additional)
print("✓ Saved additional keymaps to: " .. file)

local loaded_additional = persistence.load_additional_keymaps()
assert(#loaded_additional == 2, "Should load 2 additional keymaps")
print("✓ Loaded " .. #loaded_additional .. " additional keymaps")

print("\n8. Testing get_all_keymaps...")
local all = persistence.get_all_keymaps()
assert(#all == 7, "Should have 7 total keymaps (5 internal + 2 additional)")
print("✓ Total keymaps: " .. #all)

print("\n9. Checking file structure...")
local axle_dir = persistence.get_axle_dir()
local internal_file = persistence.get_internal_keymaps_file()
local additional_file = persistence.get_additional_keymaps_file()

assert(vim.fn.isdirectory(axle_dir) == 1, "Axle directory should exist")
assert(vim.fn.filereadable(internal_file) == 1, "Internal keymaps file should exist")
assert(vim.fn.filereadable(additional_file) == 1, "Additional keymaps file should exist")
print("✓ File structure correct:")
print("  - " .. internal_file)
print("  - " .. additional_file)

print("\n=== All Tests Passed! ===\n")

-- Show notifications
print("\nNotifications received:")
for i, notif in ipairs(notifications) do
	print(i .. ". " .. notif.msg)
end

-- Restore original stdpath
vim.fn.stdpath = original_stdpath

-- Cleanup
os.execute("rm -rf " .. test_dir)
print("\nTest directory cleaned up.")
