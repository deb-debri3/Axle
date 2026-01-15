#!/usr/bin/env lua

-- Quick test script for storage module
-- Run with: lua test_storage_v2.lua

print("=== Axle Storage Module Test ===\n")

-- Mock vim functions for testing
local function mock_vim()
	_G.vim = {
		fn = {
			stdpath = function(what)
				if what == "data" then
					return "/tmp/axle_test_" .. os.time()
				end
			end,
			mkdir = function(path, flags)
				os.execute("mkdir -p " .. path)
			end,
			filereadable = function(path)
				local f = io.open(path, "r")
				if f then
					f:close()
					return 1
				end
				return 0
			end,
			readfile = function(path)
				local f = io.open(path, "r")
				if not f then return {} end
				local lines = {}
				for line in f:lines() do
					table.insert(lines, line)
				end
				f:close()
				return lines
			end,
			writefile = function(lines, path)
				local f = io.open(path, "w")
				if not f then return end
				for _, line in ipairs(lines) do
					f:write(line .. "\n")
				end
				f:close()
			end,
			json_encode = function(data)
				-- Simple JSON encoder for testing
				local json = require("dkjson") or require("cjson") or require("json")
				if json then
					return json.encode(data)
				end
				-- Fallback: basic serialization
				return vim.inspect(data)
			end,
			json_decode = function(str)
				local json = require("dkjson") or require("cjson") or require("json")
				if json then
					return json.decode(str)
				end
				-- Fallback: loadstring
				return loadstring("return " .. str)()
			end,
			rename = function(old, new)
				os.rename(old, new)
			end,
		},
		inspect = function(data)
			return string.format("%q", tostring(data))
		end,
	}
end

-- Initialize mock
mock_vim()

-- Load storage module
package.path = package.path .. ";./lua/?.lua;./lua/axle/?.lua"
local ok, storage = pcall(require, "storage")

if not ok then
	print("❌ Failed to load storage module: " .. tostring(storage))
	os.exit(1)
end

print("✅ Storage module loaded successfully\n")

-- Test 1: Get storage directory
print("📂 Test 1: Storage directory")
local dir = storage.get_axle_dir()
print("   Directory: " .. dir)
print("   ✓ Pass\n")

-- Test 2: Get storage file path
print("📄 Test 2: Storage file path")
local file = storage.get_storage_file()
print("   File: " .. file)
print("   ✓ Pass\n")

-- Test 3: Load empty storage
print("💾 Test 3: Load empty storage")
local data = storage.load()
print("   Auto keymaps: " .. #data.auto)
print("   Manual keymaps: " .. #data.manual)
print("   Last sync: " .. tostring(data.last_sync))
assert(#data.auto == 0, "Auto should be empty")
assert(#data.manual == 0, "Manual should be empty")
print("   ✓ Pass\n")

-- Test 4: Sync auto keymaps
print("🔄 Test 4: Sync auto keymaps")
local scanned = {
	{ mode = "n", key = "<leader>ff", description = "Find files" },
	{ mode = "n", key = "<leader>fg", description = "Live grep" },
	{ mode = "i", key = "<C-s>", description = "Save file" },
}
local result = storage.sync_auto_keymaps(scanned)
print("   Total: " .. result.total)
print("   New: " .. result.new)
print("   Updated: " .. result.updated)
assert(result.total == 3, "Should have 3 total")
assert(result.new == 3, "Should have 3 new")
print("   ✓ Pass\n")

-- Test 5: Load after sync
print("📖 Test 5: Load after sync")
local loaded = storage.load()
print("   Auto keymaps: " .. #loaded.auto)
assert(#loaded.auto == 3, "Should have 3 auto keymaps")
print("   ✓ Pass\n")

-- Test 6: Check keymap exists
print("🔍 Test 6: Check keymap exists")
local exists, category, desc = storage.keymap_exists("n", "<leader>ff")
print("   Exists: " .. tostring(exists))
print("   Category: " .. tostring(category))
print("   Description: " .. tostring(desc))
assert(exists == true, "Should exist")
assert(category == "auto", "Should be auto")
print("   ✓ Pass\n")

-- Test 7: Add manual keymap
print("➕ Test 7: Add manual keymap")
storage.add_manual_keymap("n", "<leader>xx", "Custom action")
local all = storage.get_all_keymaps()
print("   Total keymaps: " .. #all)
assert(#all == 4, "Should have 4 total (3 auto + 1 manual)")
print("   ✓ Pass\n")

-- Test 8: Get all keymaps
print("📋 Test 8: Get all keymaps")
local all_keymaps = storage.get_all_keymaps()
local auto_count = 0
local manual_count = 0
for _, km in ipairs(all_keymaps) do
	if km.category == "auto" then
		auto_count = auto_count + 1
	elseif km.category == "manual" then
		manual_count = manual_count + 1
	end
end
print("   Auto: " .. auto_count)
print("   Manual: " .. manual_count)
assert(auto_count == 3, "Should have 3 auto")
assert(manual_count == 1, "Should have 1 manual")
print("   ✓ Pass\n")

-- Test 9: Update sync (add new keymap)
print("🔄 Test 9: Update sync with new keymap")
local updated_scanned = {
	{ mode = "n", key = "<leader>ff", description = "Find files" },
	{ mode = "n", key = "<leader>fg", description = "Live grep" },
	{ mode = "i", key = "<C-s>", description = "Save file" },
	{ mode = "n", key = "<leader>new", description = "New keymap" },
}
local update_result = storage.sync_auto_keymaps(updated_scanned)
print("   Total: " .. update_result.total)
print("   New: " .. update_result.new)
print("   Updated: " .. update_result.updated)
assert(update_result.total == 4, "Should have 4 total")
assert(update_result.new == 1, "Should have 1 new")
print("   ✓ Pass\n")

-- Test 10: Storage info
print("ℹ️  Test 10: Storage info")
local info = storage.get_info()
print("   Auto count: " .. info.auto_count)
print("   Manual count: " .. info.manual_count)
print("   Total count: " .. info.total_count)
print("   Last sync: " .. tostring(info.last_sync))
print("   File: " .. info.file)
assert(info.auto_count == 4, "Should have 4 auto")
assert(info.manual_count == 1, "Should have 1 manual")
assert(info.total_count == 5, "Should have 5 total")
print("   ✓ Pass\n")

-- Summary
print("=" .. string.rep("=", 50))
print("✅ ALL TESTS PASSED!")
print("=" .. string.rep("=", 50))

-- Cleanup
os.execute("rm -rf " .. dir)
print("\n🧹 Cleanup: Test directory removed")
