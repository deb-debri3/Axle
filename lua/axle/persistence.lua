-- Axle - Persistence Module
-- Handles tracking of internal keymaps and additional user keymaps
local M = {}

-- Get axle data directory
function M.get_axle_dir()
	local data_dir = vim.fn.stdpath("data")
	local axle_dir = data_dir .. "/axle"
	vim.fn.mkdir(axle_dir, "p")
	return axle_dir
end

-- File paths
function M.get_internal_keymaps_file()
	return M.get_axle_dir() .. "/axle-internal-keymaps.lua"
end

function M.get_additional_keymaps_file()
	return M.get_axle_dir() .. "/axle-additional-keymaps.lua"
end

-- Check if this is first installation
function M.is_first_install()
	return vim.fn.filereadable(M.get_internal_keymaps_file()) == 0
end

-- Save internal keymaps (baseline from keymaps.lua)
function M.save_internal_keymaps(keymaps)
	local file = M.get_internal_keymaps_file()
	local content = "-- Auto-generated internal keymaps baseline\n"
	content = content .. "-- Created: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
	content = content .. "return {\n"
	
	for _, km in ipairs(keymaps) do
		content = content .. string.format(
			'  { mode = "%s", key = "%s", description = "%s", source = "%s" },\n',
			km.mode,
			km.key,
			km.description:gsub('"', '\\"'),
			km.source or "config"
		)
	end
	
	content = content .. "}\n"
	vim.fn.writefile(vim.split(content, "\n"), file)
	return file
end

-- Load internal keymaps
function M.load_internal_keymaps()
	local file = M.get_internal_keymaps_file()
	if vim.fn.filereadable(file) == 1 then
		local ok, keymaps = pcall(dofile, file)
		if ok and keymaps then
			return keymaps
		end
	end
	return {}
end

-- Save additional keymaps (user manually added)
function M.save_additional_keymaps(keymaps)
	local file = M.get_additional_keymaps_file()
	local content = "-- User-added additional keymaps\n"
	content = content .. "-- Last updated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
	content = content .. "return {\n"
	
	for _, km in ipairs(keymaps) do
		content = content .. string.format(
			'  { mode = "%s", key = "%s", description = "%s" },\n',
			km.mode,
			km.key,
			km.description:gsub('"', '\\"')
		)
	end
	
	content = content .. "}\n"
	vim.fn.writefile(vim.split(content, "\n"), file)
	return file
end

-- Load additional keymaps
function M.load_additional_keymaps()
	local file = M.get_additional_keymaps_file()
	if vim.fn.filereadable(file) == 1 then
		local ok, keymaps = pcall(dofile, file)
		if ok and keymaps then
			return keymaps
		end
	end
	return {}
end

-- Initialize: Create baseline on first install or sync new keymaps
function M.initialize(current_keymaps)
	if M.is_first_install() then
		-- First installation - create baseline
		local file = M.save_internal_keymaps(current_keymaps)
		vim.notify(
			string.format("Axle: Created internal keymaps baseline (%d keymaps)\nFile: %s", #current_keymaps, file),
			vim.log.levels.INFO
		)
		return true
	else
		-- Not first install - sync new keymaps from keymaps.lua
		return M.sync_new_keymaps(current_keymaps)
	end
end

-- Sync new keymaps: Compare current keymaps.lua with internal baseline and add new ones
function M.sync_new_keymaps(current_keymaps)
	local internal_keymaps = M.load_internal_keymaps()
	
	-- Create lookup table for existing internal keymaps
	local internal_lookup = {}
	for _, km in ipairs(internal_keymaps) do
		local key_id = km.mode .. ":" .. km.key
		internal_lookup[key_id] = true
	end
	
	-- Find new keymaps
	local new_keymaps = {}
	for _, km in ipairs(current_keymaps) do
		local key_id = km.mode .. ":" .. km.key
		if not internal_lookup[key_id] then
			table.insert(new_keymaps, km)
		end
	end
	
	-- If new keymaps found, add them to internal baseline
	if #new_keymaps > 0 then
		-- Merge and save
		for _, km in ipairs(new_keymaps) do
			table.insert(internal_keymaps, km)
		end
		
		M.save_internal_keymaps(internal_keymaps)
		
		vim.notify(
			string.format("Axle: Synced %d new keymaps to internal baseline", #new_keymaps),
			vim.log.levels.INFO
		)
		return true
	end
	
	return false
end

-- Get all keymaps (internal + additional)
function M.get_all_keymaps()
	local all_keymaps = {}
	
	-- Add internal keymaps
	local internal = M.load_internal_keymaps()
	for _, km in ipairs(internal) do
		table.insert(all_keymaps, km)
	end
	
	-- Add additional keymaps
	local additional = M.load_additional_keymaps()
	for _, km in ipairs(additional) do
		km.source = "additional"
		table.insert(all_keymaps, km)
	end
	
	return all_keymaps
end

-- Migrate old manual_keymaps.lua to new system
function M.migrate_old_manual_keymaps()
	local old_file = M.get_axle_dir() .. "/manual_keymaps.lua"
	if vim.fn.filereadable(old_file) == 1 then
		local ok, old_keymaps = pcall(dofile, old_file)
		if ok and old_keymaps and #old_keymaps > 0 then
			M.save_additional_keymaps(old_keymaps)
			vim.notify(
				string.format("Axle: Migrated %d keymaps from old format to axle-additional-keymaps.lua", #old_keymaps),
				vim.log.levels.INFO
			)
			-- Optionally backup and remove old file
			vim.fn.rename(old_file, old_file .. ".backup")
		end
	end
end

return M
