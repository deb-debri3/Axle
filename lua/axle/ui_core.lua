-- Axle - UI Core Module
local scanner = require("axle.keymap_scanner")
local storage = require("axle.storage")
local M = {}

-- Store manual keymaps in memory (before saving)
M.manual_keymaps = {}

-- Check if keymap already exists
function M.keymap_exists(mode, key)
	-- Check in storage (auto + manual from file)
	local exists, category, desc = storage.keymap_exists(mode, key)
	if exists then
		return true, category, desc
	end

	-- Check in memory (unsaved manual keymaps)
	for _, km in ipairs(M.manual_keymaps) do
		if km.mode == mode and km.key == key then
			return true, "manual (unsaved)", km.description
		end
	end

	return false
end

-- Add a keymap manually with validation
function M.add_keymap(mode, key, desc)
	local exists, category, existing_desc = M.keymap_exists(mode, key)

	if exists then
		vim.notify(
			string.format(
				"⚠️  Keymap already exists!\n[%s] %s → %s\nCategory: %s",
				mode:upper(),
				key,
				existing_desc,
				category
			),
			vim.log.levels.WARN,
			{ title = "Axle - Duplicate Keymap" }
		)
		return false
	end

	table.insert(M.manual_keymaps, {
		mode = mode or "",
		key = key or "",
		description = desc or "",
		category = "manual",
	})

	return true
end

-- Show keymaps using Telescope (enhanced search)
function M.show()
	-- Check if telescope is available
	local ok, telescope = pcall(require, "telescope")
	if not ok then
		M.show_simple()
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Get all keymaps from storage (auto + manual)
	local all_keymaps = storage.get_all_keymaps()
	
	-- Add unsaved manual keymaps from memory
	for _, km in ipairs(M.manual_keymaps) do
		km.category = "manual (unsaved)"
		table.insert(all_keymaps, km)
	end

	-- Format for display
	local keymap_entries = {}

	for _, km in ipairs(all_keymaps) do
		local mode = km.mode:upper()
		local key = km.key
		local desc = km.description
		local category = km.category or "auto"
		
		-- Add favorite indicator
		local favorite_icon = (km.favorite and "⭐ ") or "   "

		local display = string.format(
			"%s%-6s %-30s %-40s [%s]",
			favorite_icon,
			mode,
			key,
			desc,
			category
		)
		table.insert(keymap_entries, {
			display = display,
			keymap = km,
		})
	end

	pickers
		.new({}, {
			prompt_title = "Axle - Browse & Search Keymaps",
			finder = finders.new_table({
				results = keymap_entries,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.display,
						ordinal = entry.is_header and "" or entry.display, -- Don't search headers
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					if selection and not selection.value.is_header then
						local km = selection.value.keymap
						actions.close(prompt_bufnr)

						-- Show detailed info with options
						local info = string.format(
							"Mode: %s\nKey: %s\nDescription: %s\nCategory: %s%s",
							km.mode:upper(),
							km.key,
							km.description,
							km.category or "auto",
							km.line_number and ("\nLine: " .. km.line_number) or ""
						)

						vim.notify(info, vim.log.levels.INFO, { title = "Keymap Info" })
					end
				end)

				-- Add mapping to delete manual keymap with <C-d> (normal mode)
				map("n", "<C-d>", function()
					local selection = action_state.get_selected_entry()
					if selection and not selection.value.is_header then
						local km = selection.value.keymap
						
						-- Only allow deleting manual keymaps
						if km.category == "manual" then
							actions.close(prompt_bufnr)
							
							vim.ui.select(
								{ "Yes, delete it", "No, cancel" },
								{
									prompt = string.format(
										"Delete manual keymap?\n[%s] %s → %s",
										km.mode:upper(),
										km.key,
										km.description
									),
								},
								function(choice)
									if choice == "Yes, delete it" then
										local removed = storage.remove_manual_keymap(km.mode, km.key)
										if removed then
											vim.notify(
												string.format("✓ Deleted: [%s] %s", km.mode:upper(), km.key),
												vim.log.levels.INFO,
												{ title = "Axle - Deleted" }
											)
										else
											vim.notify(
												"Failed to delete keymap",
												vim.log.levels.ERROR,
												{ title = "Axle - Error" }
											)
										end
									end
								end
							)
						elseif km.category == "manual (unsaved)" then
							-- Remove from memory
							actions.close(prompt_bufnr)
							
							vim.ui.select(
								{ "Yes, delete it", "No, cancel" },
								{
									prompt = string.format(
										"Delete unsaved keymap?\n[%s] %s → %s",
										km.mode:upper(),
										km.key,
										km.description
									),
								},
								function(choice)
									if choice == "Yes, delete it" then
										for i, mkm in ipairs(M.manual_keymaps) do
											if mkm.mode == km.mode and mkm.key == km.key then
												table.remove(M.manual_keymaps, i)
												vim.notify(
													string.format("✓ Deleted unsaved: [%s] %s", km.mode:upper(), km.key),
													vm.log.levels.INFO,
													{ title = "Axle - Deleted" }
												)
												break
											end
										end
									end
								end
							)
						else
							vim.notify(
								"Cannot delete auto keymaps. Edit your keymaps.lua file instead.",
								vim.log.levels.WARN,
								{ title = "Axle - Auto Keymap" }
							)
						end
					end
				end)

				-- Also add <C-d> in insert mode for convenience
				map("i", "<C-d>", function()
					local selection = action_state.get_selected_entry()
					if selection and not selection.value.is_header then
						local km = selection.value.keymap
						
						-- Only allow deleting manual keymaps
						if km.category == "manual" then
							actions.close(prompt_bufnr)
							
							vim.ui.select(
								{ "Yes, delete it", "No, cancel" },
								{
									prompt = string.format(
										"Delete manual keymap?\n[%s] %s → %s",
										km.mode:upper(),
										km.key,
										km.description
									),
								},
								function(choice)
									if choice == "Yes, delete it" then
										local removed = storage.remove_manual_keymap(km.mode, km.key)
										if removed then
											vim.notify(
												string.format("✓ Deleted: [%s] %s", km.mode:upper(), km.key),
												vim.log.levels.INFO,
												{ title = "Axle - Deleted" }
											)
										end
									end
								end
							)
						elseif km.category == "manual (unsaved)" then
							-- Remove from memory
							actions.close(prompt_bufnr)
							
							vim.ui.select(
								{ "Yes, delete it", "No, cancel" },
								{
									prompt = string.format(
										"Delete unsaved keymap?\n[%s] %s → %s",
										km.mode:upper(),
										km.key,
										km.description
									),
								},
								function(choice)
									if choice == "Yes, delete it" then
										for i, mkm in ipairs(M.manual_keymaps) do
											if mkm.mode == km.mode and mkm.key == km.key then
												table.remove(M.manual_keymaps, i)
												vim.notify(
													string.format("✓ Deleted unsaved: [%s] %s", km.mode:upper(), km.key),
													vim.log.levels.INFO,
													{ title = "Axle - Deleted" }
												)
												break
											end
										end
									end
								end
							)
						else
							vim.notify(
								"Cannot delete auto keymaps. Edit your keymaps.lua file instead.",
								vim.log.levels.WARN,
								{ title = "Axle - Auto Keymap" }
							)
						end
					end
				end)

				-- Add mapping to toggle favorite with <C-s> (normal mode)
				map("n", "<C-s>", function()
					local selection = action_state.get_selected_entry()
					if selection and not selection.value.is_header then
						local km = selection.value.keymap
						
						-- Don't allow starring unsaved keymaps
						if km.category == "manual (unsaved)" then
							vim.notify(
								"Save the keymap first before starring",
								vim.log.levels.WARN,
								{ title = "Axle" }
							)
							return
						end
						
						-- Toggle favorite
						local is_favorite = storage.toggle_favorite(km.mode, km.key, km.category)
						
						if is_favorite then
							vim.notify(
								string.format("⭐ Starred: [%s] %s", km.mode:upper(), km.key),
								vim.log.levels.INFO,
								{ title = "Axle" }
							)
						else
							vim.notify(
								string.format("Unstarred: [%s] %s", km.mode:upper(), km.key),
								vim.log.levels.INFO,
								{ title = "Axle" }
							)
						end
						
						-- Refresh picker
						actions.close(prompt_bufnr)
						vim.schedule(function()
							M.show()
						end)
					end
				end)

				-- Add mapping to go to keymap definition
				map("i", "<C-g>", function()
					local selection = action_state.get_selected_entry()
					if selection and not selection.value.is_header and selection.value.keymap.line_number then
						actions.close(prompt_bufnr)
						
						-- Only auto keymaps have source file info
						if selection.value.keymap.category ~= "auto" then
							vim.notify("Manual keymaps don't have source file location", vim.log.levels.INFO)
							return
						end
						
						local config_path = vim.fn.stdpath("config")
						local source_file = selection.value.keymap.source
						
						if not source_file then
							vim.notify("Source file information not available", vim.log.levels.WARN)
							return
						end
						
						-- Construct full path
						local possible_paths = {
							config_path .. "/lua/config/" .. source_file,
							config_path .. "/lua/" .. source_file, 
							config_path .. "/lua/core/" .. source_file,
							config_path .. "/" .. source_file
						}
						
						local target_file = nil
						for _, path in ipairs(possible_paths) do
							if vim.fn.filereadable(path) == 1 then
								target_file = path
								break
							end
						end
						
						if target_file then
							vim.cmd("edit " .. target_file)
							vim.api.nvim_win_set_cursor(0, { selection.value.keymap.line_number, 0 })
						else
							vim.notify("Could not find keymap file: " .. source_file, vim.log.levels.WARN)
						end
					end
				end)

				-- Add mapping to add current search as manual keymap
				map("i", "<C-a>", function()
					local current_input = action_state.get_current_line()
					if current_input and current_input ~= "" then
						actions.close(prompt_bufnr)
						-- Ask for mode and description
						vim.ui.input({ prompt = "Mode (n/i/v/x): ", default = "n" }, function(mode)
							if mode then
								local exists, category, existing_desc = M.keymap_exists(mode, current_input)
								if exists then
									vim.notify(
										string.format(
											"⚠️  Keymap [%s] %s already exists!\nCategory: %s → %s",
											mode:upper(),
											current_input,
											category,
											existing_desc
										),
										vim.log.levels.WARN,
										{ title = "Axle - Duplicate" }
									)
								else
									vim.ui.input({ prompt = "Description: " }, function(desc)
										if desc then
											local success = M.add_keymap(mode, current_input, desc)
											if success then
												vim.notify(
													"✓ Added keymap: ["
														.. mode:upper()
														.. "] "
														.. current_input
														.. " → "
														.. desc,
													vim.log.levels.INFO,
													{ title = "Axle" }
												)
											end
										end
									end)
								end
							end
						end)
					end
				end)

				return true
			end,
		})
		:find()
end

-- Fallback simple UI if telescope not available
function M.show_simple()
	local all_keymaps = storage.get_all_keymaps()

	-- Add unsaved manual keymaps from memory
	for _, km in ipairs(M.manual_keymaps) do
		km.category = "manual (unsaved)"
		table.insert(all_keymaps, km)
	end

	local lines = {}

	-- Display all keymaps in 3-column format
	for _, km in ipairs(all_keymaps) do
		local mode = km.mode:upper()
		local key = km.key
		local desc = km.description

		-- Truncate if too long
		if #key > 30 then
			key = key:sub(1, 27) .. "..."
		end
		if #desc > 54 then
			desc = desc:sub(1, 51) .. "..."
		end

		local category = km.category or "auto"
		table.insert(lines, string.format("%-6s %-30s %-40s [%s]", mode, key, desc, category))
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = 100,
		height = math.min(30, #lines + 2),
		row = math.floor((vim.o.lines - math.min(30, #lines + 2)) / 2),
		col = math.floor((vim.o.columns - 100) / 2),
		style = "minimal",
		border = "rounded",
	})

	-- Set keymap to close with 'q'
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { silent = true })
end

-- Quick search function
function M.quick_search(query)
	local all_keymaps = storage.get_all_keymaps()

	-- Add unsaved manual keymaps from memory
	for _, km in ipairs(M.manual_keymaps) do
		km.category = "manual (unsaved)"
		table.insert(all_keymaps, km)
	end

	-- Filter based on query
	local filtered = {}
	query = query:lower()

	for _, km in ipairs(all_keymaps) do
		if km.key:lower():match(query) or km.description:lower():match(query) or km.mode:lower():match(query) then
			table.insert(filtered, km)
		end
	end

	-- Display results
	if #filtered == 0 then
		vim.notify("No keymaps found matching: '" .. query .. "'", vim.log.levels.WARN)
		return
	end

	local lines = {}
	for _, km in ipairs(filtered) do
		table.insert(lines, string.format("%-4s │ %-25s │ %s", km.mode:upper(), km.key, km.description))
	end

	vim.ui.select(lines, {
		prompt = "Keymaps matching '" .. query .. "' (" .. #filtered .. " found):",
	}, function(selected)
		if selected then
			-- Find the selected keymap and show info
			local idx = nil
			for i, line in ipairs(lines) do
				if line == selected then
					idx = i
					break
				end
			end

			if idx then
				local km = filtered[idx]
				local info = string.format(
					"Mode: %s\nKey: %s\nDescription: %s\nCategory: %s%s",
					km.mode:upper(),
					km.key,
					km.description,
					km.category or "auto",
					km.line_number and ("\nLine: " .. km.line_number) or ""
				)
				vim.notify(info, vim.log.levels.INFO, { title = "Keymap Info" })
			end
		end
	end)
end

-- Function to interactively add a keymap
function M.add_keymap_interactive()
	vim.ui.input({ prompt = "Keymap (e.g., <leader>ff): " }, function(key)
		if key and key ~= "" then
			vim.ui.input({ prompt = "Mode (n/i/v/x/t/c/s/o): ", default = "n" }, function(mode)
				if mode and mode ~= "" then
					-- Check for duplicates first
					local exists, category, existing_desc = M.keymap_exists(mode, key)
					if exists then
						vim.ui.select({ "Overwrite existing", "Cancel" }, {
							prompt = string.format(
								"Keymap [%s] %s already exists (%s: %s)",
								mode:upper(),
								key,
								category,
								existing_desc
							),
						}, function(choice)
							if choice == "Overwrite existing" then
								vim.ui.input({ prompt = "Description: " }, function(desc)
									if desc and desc ~= "" then
										-- Remove from memory if exists
										for i, km in ipairs(M.manual_keymaps) do
											if km.mode == mode and km.key == key then
												table.remove(M.manual_keymaps, i)
												break
											end
										end
										
										table.insert(M.manual_keymaps, {
											mode = mode,
											key = key,
											description = desc,
											category = "manual",
										})
										vim.notify(
											"✓ Overwritten keymap: ["
												.. mode:upper()
												.. "] "
												.. key
												.. " → "
												.. desc,
											vim.log.levels.INFO,
											{ title = "Axle" }
										)
									end
								end)
							end
						end)
					else
						vim.ui.input({ prompt = "Description: " }, function(desc)
							if desc and desc ~= "" then
								local success = M.add_keymap(mode, key, desc)
								if success then
									vim.notify(
										"✓ Added keymap: [" .. mode:upper() .. "] " .. key .. " → " .. desc,
										vim.log.levels.INFO,
										{ title = "Axle" }
									)
								end
							end
						end)
					end
				end
			end)
		end
	end)
end

-- Save manual keymaps to storage
function M.save_manual_keymaps()
	if #M.manual_keymaps == 0 then
		vim.notify("No unsaved manual keymaps to save", vim.log.levels.WARN)
		return
	end
	
	-- Get existing storage and merge
	local existing = storage.load()
	for _, km in ipairs(M.manual_keymaps) do
		table.insert(existing.manual, km)
	end
	
	local file = storage.save_manual_keymaps(existing.manual)
	
	vim.notify(
		string.format("Saved %d manual keymaps to storage\nFile: %s", #M.manual_keymaps, file),
		vim.log.levels.INFO
	)
	
	-- Clear memory after saving
	M.manual_keymaps = {}
end

-- Initialize storage system (called on plugin load)
function M.initialize()
	-- Migrate from old persistence system if exists
	local migrated = storage.migrate_from_old_system()
	if migrated then
		vim.notify("Migrated from old storage system to new format", vim.log.levels.INFO)
	end
	
	-- Scan current keymaps from config
	local scanned_keymaps = scanner.scan_keymaps_file()
	
	-- Sync auto keymaps (first time or update)
	local sync_result = storage.sync_auto_keymaps(scanned_keymaps)
	
	if sync_result.new > 0 or sync_result.updated > 0 then
		vim.notify(
			string.format(
				"Axle: Synced keymaps (Total: %d, New: %d, Updated: %d)",
				sync_result.total,
				sync_result.new,
				sync_result.updated
			),
			vim.log.levels.INFO
		)
	end
end

-- Rescan and update auto keymaps (called by <leader>mbr)
function M.rescan_and_update()
	local scanned_keymaps = scanner.scan_keymaps_file()
	local sync_result = storage.sync_auto_keymaps(scanned_keymaps)
	
	vim.notify(
		string.format(
			"Axle: Rescanned and updated\nTotal: %d | New: %d | Updated: %d",
			sync_result.total,
			sync_result.new,
			sync_result.updated
		),
		vim.log.levels.INFO
	)
end

-- Remove manual keymap interactively
function M.remove_keymap_interactive()
	-- Get all manual keymaps (saved + unsaved)
	local stored_manual = storage.load().manual
	local all_manual = {}
	
	-- Add saved manual keymaps
	for _, km in ipairs(stored_manual) do
		table.insert(all_manual, {
			keymap = km,
			display = string.format("[%s] %s - %s", km.mode:upper(), km.key, km.description),
			saved = true
		})
	end
	
	-- Add unsaved manual keymaps
	for _, km in ipairs(M.manual_keymaps) do
		table.insert(all_manual, {
			keymap = km,
			display = string.format("[%s] %s - %s (unsaved)", km.mode:upper(), km.key, km.description),
			saved = false
		})
	end
	
	if #all_manual == 0 then
		vim.notify("No manual keymaps to remove", vim.log.levels.WARN, { title = "Axle" })
		return
	end
	
	-- Create list for selection
	local options = {}
	for _, item in ipairs(all_manual) do
		table.insert(options, item.display)
	end
	
	vim.ui.select(options, {
		prompt = "Select manual keymap to remove:",
	}, function(choice, idx)
		if not choice then return end
		
		local selected = all_manual[idx]
		local km = selected.keymap
		
		-- Confirm deletion
		vim.ui.select(
			{ "Yes, delete it", "No, cancel" },
			{
				prompt = string.format(
					"Delete keymap?\n[%s] %s → %s%s",
					km.mode:upper(),
					km.key,
					km.description,
					selected.saved and "" or " (unsaved)"
				),
			},
			function(confirm)
				if confirm == "Yes, delete it" then
					if selected.saved then
						-- Remove from storage
						local removed = storage.remove_manual_keymap(km.mode, km.key)
						if removed then
							vim.notify(
								string.format("✓ Deleted: [%s] %s", km.mode:upper(), km.key),
								vim.log.levels.INFO,
								{ title = "Axle" }
							)
						end
					else
						-- Remove from memory
						for i, mkm in ipairs(M.manual_keymaps) do
							if mkm.mode == km.mode and mkm.key == km.key then
								table.remove(M.manual_keymaps, i)
								vim.notify(
									string.format("✓ Deleted unsaved: [%s] %s", km.mode:upper(), km.key),
									vim.log.levels.INFO,
									{ title = "Axle" }
								)
								break
							end
						end
					end
				end
			end
		)
	end)
end

-- Edit manual keymap interactively
function M.edit_keymap_interactive()
	-- Get all manual keymaps (saved + unsaved)
	local stored_manual = storage.load().manual
	local all_manual = {}
	
	-- Add saved manual keymaps
	for _, km in ipairs(stored_manual) do
		table.insert(all_manual, {
			keymap = km,
			display = string.format("[%s] %s - %s", km.mode:upper(), km.key, km.description),
			saved = true
		})
	end
	
	-- Add unsaved manual keymaps
	for _, km in ipairs(M.manual_keymaps) do
		table.insert(all_manual, {
			keymap = km,
			display = string.format("[%s] %s - %s (unsaved)", km.mode:upper(), km.key, km.description),
			saved = false
		})
	end
	
	if #all_manual == 0 then
		vim.notify("No manual keymaps to edit", vim.log.levels.WARN, { title = "Axle" })
		return
	end
	
	-- Create list for selection
	local options = {}
	for _, item in ipairs(all_manual) do
		table.insert(options, item.display)
	end
	
	vim.ui.select(options, {
		prompt = "Select manual keymap to edit:",
	}, function(choice, idx)
		if not choice then return end
		
		local selected = all_manual[idx]
		local km = selected.keymap
		
		-- Edit description
		vim.ui.input({
			prompt = "New description: ",
			default = km.description
		}, function(new_desc)
			if not new_desc or new_desc == "" then return end
			
			if selected.saved then
				-- Update in storage
				local storage_data = storage.load()
				for i, stored_km in ipairs(storage_data.manual) do
					if stored_km.mode == km.mode and stored_km.key == km.key then
						storage_data.manual[i].description = new_desc
						storage.save(storage_data)
						vim.notify(
							string.format("✓ Updated: [%s] %s → %s", km.mode:upper(), km.key, new_desc),
							vim.log.levels.INFO,
							{ title = "Axle" }
						)
						break
					end
				end
			else
				-- Update in memory
				for i, mem_km in ipairs(M.manual_keymaps) do
					if mem_km.mode == km.mode and mem_km.key == km.key then
						M.manual_keymaps[i].description = new_desc
						vim.notify(
							string.format("✓ Updated (unsaved): [%s] %s → %s", km.mode:upper(), km.key, new_desc),
							vim.log.levels.INFO,
							{ title = "Axle" }
						)
						break
					end
				end
			end
		end)
	end)
end

-- Show help panel
function M.show_help()
	local help_lines = {
		"🔧 Axle - Keybindings Help",
		"",
		"MAIN COMMANDS:",
		"  <leader>mbl  →  Browse all keymaps",
		"  <leader>mbs  →  Quick search keymaps",
		"  <leader>mba  →  Add manual keymap",
		"  <leader>mbe  →  Edit manual keymap",
		"  <leader>mbd  →  Delete manual keymap",
		"  <leader>mbS  →  Save manual keymaps",
		"  <leader>mbr  →  Rescan & sync (update auto)",
		"  <leader>mbi  →  Show statistics/info",
		"  <leader>mbx  →  Export manual keymaps",
		"  <leader>mbm  →  Import manual keymaps",
		"  <leader>mbh  →  Show this help",
		"",
		"VIM COMMANDS:",
		"  :Axle        →  Browse all keymaps",
		"  :AxleAdd     →  Add manual keymap",
		"  :AxleEdit    →  Edit manual keymap",
		"  :AxleDelete  →  Delete manual keymap",
		"  :AxleInfo    →  Show statistics",
		"  :AxleExport  →  Export manual keymaps",
		"  :AxleImport  →  Import manual keymaps",
		"  :AxleSync    →  Rescan & sync",
		"  :AxleHelp    →  Show this help",
		"",
		"BROWSER KEYS (in Telescope):",
		"  <C-d>        →  Delete selected keymap",
		"  <C-s>        →  Toggle favorite (star)",
		"  <C-g>        →  Go to keymap definition",
		"",
		"TIPS:",
		"  • Auto keymaps = From your keymaps.lua",
		"  • Manual keymaps = Added by you",
		"  • ⭐ = Favorite keymap",
		"  • Press <leader>mbr after editing config",
		"  • Use <leader>mbS to save manual keymaps",
		"",
		"Press q or <Esc> to close",
	}
	
	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	
	-- Calculate window size
	local width = 60
	local height = #help_lines + 2
	
	-- Create window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " Axle Help ",
		title_pos = "center",
	})
	
	-- Set keymaps to close
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { silent = true, noremap = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { silent = true, noremap = true })
end

-- Show statistics/info
function M.show_info()
	local info = storage.get_info()
	
	local info_lines = {
		"📊 Axle - Statistics & Info",
		"",
		"KEYMAP COUNTS:",
		string.format("  Auto keymaps:      %d", info.auto_count),
		string.format("  Manual keymaps:    %d", info.manual_count),
		string.format("  Unsaved (memory):  %d", #M.manual_keymaps),
		"  " .. string.rep("─", 40),
		string.format("  Total keymaps:     %d", info.total_count + #M.manual_keymaps),
		"",
		"STORAGE INFO:",
		string.format("  Last sync:  %s", info.last_sync or "Never"),
		string.format("  File:       %s", info.file),
		"",
		"CATEGORIES:",
		"  [auto]   - Scanned from keymaps.lua",
		"  [manual] - User-added keymaps",
		"",
		"Press q or <Esc> to close",
	}
	
	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, info_lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	
	-- Calculate window size
	local width = 60
	local height = #info_lines + 2
	
	-- Create window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " Axle Info ",
		title_pos = "center",
	})
	
	-- Set keymaps to close
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { silent = true, noremap = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<CR>", { silent = true, noremap = true })
end

-- Export manual keymaps
function M.export_manual_keymaps()
	local file = storage.export_manual_keymaps()
	
	vim.notify(
		string.format("✓ Exported manual keymaps\nFile: %s", file),
		vim.log.levels.INFO,
		{ title = "Axle - Export" }
	)
	
	return file
end

-- Import manual keymaps
function M.import_manual_keymaps()
	vim.ui.input({
		prompt = "Import file path: ",
		default = vim.fn.expand("~") .. "/axle-backup-",
		completion = "file"
	}, function(filepath)
		if not filepath or filepath == "" then return end
		
		local success, result = storage.import_manual_keymaps(filepath)
		
		if success then
			local stats = result
			vim.notify(
				string.format(
					"✓ Import complete!\nImported: %d\nSkipped (duplicates): %d",
					stats.imported,
					stats.skipped
				),
				vim.log.levels.INFO,
				{ title = "Axle - Import" }
			)
		else
			vim.notify(
				string.format("✗ Import failed: %s", result),
				vim.log.levels.ERROR,
				{ title = "Axle - Import Error" }
			)
		end
	end)
end


return M
