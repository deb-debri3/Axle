-- Axle - Storage Module
-- Single-file storage with auto and manual categories

local M = {}

-- Get axle data directory
function M.get_axle_dir()
	local data_dir = vim.fn.stdpath("data")
	local axle_dir = data_dir .. "/axle"
	vim.fn.mkdir(axle_dir, "p")
	return axle_dir
end

-- Get storage file path
function M.get_storage_file()
	return M.get_axle_dir() .. "/keymaps.json"
end

-- Load storage from file
function M.load()
	local file = M.get_storage_file()
	
	if vim.fn.filereadable(file) == 0 then
		return {
			auto = {},
			manual = {},
			last_sync = nil
		}
	end
	
	local content = vim.fn.readfile(file)
	local json_str = table.concat(content, "\n")
	
	local ok, data = pcall(vim.fn.json_decode, json_str)
	if ok and data then
		data.auto = data.auto or {}
		data.manual = data.manual or {}
		return data
	end
	
	return {
		auto = {},
		manual = {},
		last_sync = nil
	}
end

-- Save storage to file
function M.save(data)
	local file = M.get_storage_file()
	
	data.last_sync = os.date("%Y-%m-%dT%H:%M:%S")
	
	local json_str = vim.fn.json_encode(data)
	vim.fn.writefile(vim.split(json_str, "\n"), file)
	
	return file
end

-- Sync auto keymaps (compare and update)
function M.sync_auto_keymaps(scanned_keymaps)
	local storage = M.load()
	
	-- Create lookup for comparison
	local scanned_lookup = {}
	for _, km in ipairs(scanned_keymaps) do
		local key_id = km.mode .. ":" .. km.key
		scanned_lookup[key_id] = km
	end
	
	local old_lookup = {}
	for _, km in ipairs(storage.auto) do
		local key_id = km.mode .. ":" .. km.key
		old_lookup[key_id] = true
	end
	
	-- Find new and updated keymaps
	local new_count = 0
	local updated_count = 0
	local new_auto = {}
	
	for _, km in ipairs(scanned_keymaps) do
		local key_id = km.mode .. ":" .. km.key
		km.category = "auto"
		table.insert(new_auto, km)
		
		if not old_lookup[key_id] then
			new_count = new_count + 1
		else
			-- Check if description changed
			for _, old_km in ipairs(storage.auto) do
				if old_km.mode == km.mode and old_km.key == km.key then
					if old_km.description ~= km.description then
						updated_count = updated_count + 1
					end
					break
				end
			end
		end
	end
	
	-- Update storage
	storage.auto = new_auto
	M.save(storage)
	
	return {
		total = #new_auto,
		new = new_count,
		updated = updated_count
	}
end

-- Add manual keymap
function M.add_manual_keymap(mode, key, description)
	local storage = M.load()
	
	table.insert(storage.manual, {
		mode = mode,
		key = key,
		description = description,
		category = "manual"
	})
	
	M.save(storage)
	return true
end

-- Save all manual keymaps (overwrite)
function M.save_manual_keymaps(manual_keymaps)
	local storage = M.load()
	
	-- Add category tag
	for _, km in ipairs(manual_keymaps) do
		km.category = "manual"
	end
	
	storage.manual = manual_keymaps
	M.save(storage)
	
	return M.get_storage_file()
end

-- Get all keymaps (merged view)
function M.get_all_keymaps()
	local storage = M.load()
	local all_keymaps = {}
	
	-- Add auto keymaps
	for _, km in ipairs(storage.auto) do
		km.category = "auto"
		table.insert(all_keymaps, km)
	end
	
	-- Add manual keymaps
	for _, km in ipairs(storage.manual) do
		km.category = "manual"
		table.insert(all_keymaps, km)
	end
	
	return all_keymaps
end

-- Check if keymap exists in storage
function M.keymap_exists(mode, key)
	local storage = M.load()
	
	-- Check in auto
	for _, km in ipairs(storage.auto) do
		if km.mode == mode and km.key == key then
			return true, "auto", km.description
		end
	end
	
	-- Check in manual
	for _, km in ipairs(storage.manual) do
		if km.mode == mode and km.key == key then
			return true, "manual", km.description
		end
	end
	
	return false
end

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

-- Get storage info
function M.get_info()
	local storage = M.load()
	return {
		auto_count = #storage.auto,
		manual_count = #storage.manual,
		total_count = #storage.auto + #storage.manual,
		last_sync = storage.last_sync,
		file = M.get_storage_file()
	}
end

-- Export manual keymaps to file
function M.export_manual_keymaps(filepath)
	local storage = M.load()
	
	-- Create export data
	local export_data = {
		exported_at = os.date("%Y-%m-%dT%H:%M:%S"),
		version = "2.3",
		manual_keymaps = storage.manual,
		count = #storage.manual
	}
	
	-- Use provided filepath or generate default
	local file = filepath or (vim.fn.expand("~") .. "/axle-backup-" .. os.date("%Y%m%d-%H%M%S") .. ".json")
	
	-- Write to file
	local json_str = vim.fn.json_encode(export_data)
	vim.fn.writefile(vim.split(json_str, "\n"), file)
	
	return file
end

-- Import manual keymaps from file
function M.import_manual_keymaps(filepath)
	if vim.fn.filereadable(filepath) == 0 then
		return false, "File not found"
	end
	
	-- Read file
	local content = vim.fn.readfile(filepath)
	local json_str = table.concat(content, "\n")
	
	-- Parse JSON
	local ok, import_data = pcall(vim.fn.json_decode, json_str)
	if not ok or not import_data then
		return false, "Invalid JSON format"
	end
	
	-- Validate structure
	if not import_data.manual_keymaps then
		return false, "Invalid Axle backup file"
	end
	
	-- Load current storage
	local storage = M.load()
	
	-- Track stats
	local stats = {
		imported = 0,
		skipped = 0,
		duplicates = {}
	}
	
	-- Import keymaps (check for duplicates)
	for _, km in ipairs(import_data.manual_keymaps) do
		local exists = false
		
		-- Check if already exists
		for _, existing in ipairs(storage.manual) do
			if existing.mode == km.mode and existing.key == km.key then
				exists = true
				table.insert(stats.duplicates, km.key)
				stats.skipped = stats.skipped + 1
				break
			end
		end
		
		-- Add if not duplicate
		if not exists then
			table.insert(storage.manual, km)
			stats.imported = stats.imported + 1
		end
	end
	
	-- Save updated storage
	M.save(storage)
	
	return true, stats
end

-- Toggle favorite status
function M.toggle_favorite(mode, key, category)
	local storage = M.load()
	local toggled = false
	
	if category == "auto" then
		for i, km in ipairs(storage.auto) do
			if km.mode == mode and km.key == key then
				storage.auto[i].favorite = not (km.favorite or false)
				toggled = storage.auto[i].favorite
				break
			end
		end
	elseif category == "manual" then
		for i, km in ipairs(storage.manual) do
			if km.mode == mode and km.key == key then
				storage.manual[i].favorite = not (km.favorite or false)
				toggled = storage.manual[i].favorite
				break
			end
		end
	end
	
	if toggled ~= false then
		M.save(storage)
	end
	
	return toggled
end

-- Migrate from old persistence system
function M.migrate_from_old_system()
	local data_dir = vim.fn.stdpath("data")
	local axle_dir = data_dir .. "/axle"
	
	local old_internal = axle_dir .. "/axle-internal-keymaps.lua"
	local old_additional = axle_dir .. "/axle-additional-keymaps.lua"
	local old_manual = axle_dir .. "/manual_keymaps.lua"
	
	local migrated = false
	local storage = M.load()
	
	-- Migrate internal -> auto
	if vim.fn.filereadable(old_internal) == 1 then
		local ok, data = pcall(dofile, old_internal)
		if ok and data then
			storage.auto = data
			migrated = true
		end
	end
	
	-- Migrate additional/manual -> manual
	if vim.fn.filereadable(old_additional) == 1 then
		local ok, data = pcall(dofile, old_additional)
		if ok and data then
			storage.manual = data
			migrated = true
		end
	elseif vim.fn.filereadable(old_manual) == 1 then
		local ok, data = pcall(dofile, old_manual)
		if ok and data then
			storage.manual = data
			migrated = true
		end
	end
	
	if migrated then
		M.save(storage)
		
		-- Backup old files
		if vim.fn.filereadable(old_internal) == 1 then
			vim.fn.rename(old_internal, old_internal .. ".backup")
		end
		if vim.fn.filereadable(old_additional) == 1 then
			vim.fn.rename(old_additional, old_additional .. ".backup")
		end
		if vim.fn.filereadable(old_manual) == 1 then
			vim.fn.rename(old_manual, old_manual .. ".backup")
		end
		
		return true
	end
	
	return false
end

return M
