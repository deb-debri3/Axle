-- Axle - UI Core Module
local scanner = require("axle.keymap_scanner")
local M = {}

-- Store manual keymaps
M.manual_keymaps = {}

-- Check if keymap already exists
function M.keymap_exists(mode, key)
	-- Check in config file keymaps
	local file_keymaps = scanner.scan_keymaps_file()
	for _, km in ipairs(file_keymaps) do
		if km.mode == mode and km.key == key then
			return true, "config file", km.description
		end
	end

	-- Check in manual keymaps
	for _, km in ipairs(M.manual_keymaps) do
		if km.mode == mode and km.key == key then
			return true, "manual", km.description
		end
	end

	return false
end

-- Add a keymap manually with validation
function M.add_keymap(mode, key, desc)
	local exists, source, existing_desc = M.keymap_exists(mode, key)

	if exists then
		vim.notify(
			string.format(
				"⚠️  Keymap already exists!\n[%s] %s → %s\nSource: %s",
				mode:upper(),
				key,
				existing_desc,
				source
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
		source = "manual",
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

	-- Get only keymaps from config file (not runtime)
	local file_keymaps = scanner.scan_keymaps_file()

	-- Add manual keymaps
	for _, km in ipairs(M.manual_keymaps) do
		table.insert(file_keymaps, km)
	end

	-- Group keymaps by mode for better organization
	local grouped_keymaps = {}
	local mode_counts = {}

	for _, km in ipairs(file_keymaps) do
		local mode = km.mode:upper()
		if not grouped_keymaps[mode] then
			grouped_keymaps[mode] = {}
			mode_counts[mode] = 0
		end
		table.insert(grouped_keymaps[mode], km)
		mode_counts[mode] = mode_counts[mode] + 1
	end

	-- Format for display
	local keymap_entries = {}

	for _, km in ipairs(file_keymaps) do
		local mode = km.mode:upper()
		local key = km.key
		local desc = km.description

		local source = km.source == "manual" and "manual" or "autoscan"
		local display = string.format("%-6s %-30s %-40s %s", mode, key, desc, source)
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

						-- Show detailed info
						local info = string.format(
							"Mode: %s\nKey: %s\nDescription: %s\nSource: %s%s",
							km.mode:upper(),
							km.key,
							km.description,
							km.source,
							km.line_number and ("\nLine: " .. km.line_number) or ""
						)

						vim.notify(info, vim.log.levels.INFO, { title = "Keymap Info" })
					end
				end)

				-- Add mapping to go to keymap definition
				map("i", "<C-g>", function()
					local selection = action_state.get_selected_entry()
					if selection and not selection.value.is_header and selection.value.keymap.line_number then
						actions.close(prompt_bufnr)
						local keymaps_file = vim.fn.stdpath("config") .. "/lua/config/keymaps.lua"
						vim.cmd("edit " .. keymaps_file)
						vim.api.nvim_win_set_cursor(0, { selection.value.keymap.line_number, 0 })
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
								local exists, source, existing_desc = M.keymap_exists(mode, current_input)
								if exists then
									vim.notify(
										string.format(
											"⚠️  Keymap [%s] %s already exists!\nSource: %s → %s",
											mode:upper(),
											current_input,
											source,
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
	local file_keymaps = scanner.scan_keymaps_file()

	-- Add manual keymaps
	for _, km in ipairs(M.manual_keymaps) do
		table.insert(file_keymaps, km)
	end

	local lines = {}

	-- Display all keymaps in 3-column format
	for _, km in ipairs(file_keymaps) do
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

		-- Simple format without borders
		local source = km.source == "manual" and "manual" or "autoscan"
		table.insert(lines, string.format("%-6s %-30s %-40s %s", mode, key, desc, source))
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
	local file_keymaps = scanner.scan_keymaps_file()

	-- Add manual keymaps
	for _, km in ipairs(M.manual_keymaps) do
		table.insert(file_keymaps, km)
	end

	-- Filter based on query
	local filtered = {}
	query = query:lower()

	for _, km in ipairs(file_keymaps) do
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
					"Mode: %s\nKey: %s\nDescription: %s\nSource: %s%s",
					km.mode:upper(),
					km.key,
					km.description,
					km.source,
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
					local exists, source, existing_desc = M.keymap_exists(mode, key)
					if exists then
						vim.ui.select({ "Overwrite existing", "Cancel" }, {
							prompt = string.format(
								"Keymap [%s] %s already exists (%s: %s)",
								mode:upper(),
								key,
								source,
								existing_desc
							),
						}, function(choice)
							if choice == "Overwrite existing" then
								-- Remove existing manual keymap if it exists
								for i, km in ipairs(M.manual_keymaps) do
									if km.mode == mode and km.key == key then
										table.remove(M.manual_keymaps, i)
										break
									end
								end

								vim.ui.input({ prompt = "Description: " }, function(desc)
									if desc and desc ~= "" then
										table.insert(M.manual_keymaps, {
											mode = mode,
											key = key,
											description = desc,
											source = "manual",
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

-- Function to save manual keymaps to a file (optional persistence)
function M.save_manual_keymaps()
	local data_dir = vim.fn.stdpath("data")
	local axle_dir = data_dir .. "/axle"
	local manual_file = axle_dir .. "/manual_keymaps.lua"
	
	-- Create axle data directory if it doesn't exist
	vim.fn.mkdir(axle_dir, "p")

	local content = "-- Auto-generated manual keymaps\nreturn {\n"
	for _, km in ipairs(M.manual_keymaps) do
		content = content
			.. string.format('  { mode = "%s", key = "%s", description = "%s" },\n', km.mode, km.key, km.description)
	end
	content = content .. "}\n"

	vim.fn.writefile(vim.split(content, "\n"), manual_file)
	vim.notify("Manual keymaps saved to " .. manual_file, vim.log.levels.INFO)
end

-- Function to load manual keymaps from file
function M.load_manual_keymaps()
	local data_dir = vim.fn.stdpath("data")
	local axle_dir = data_dir .. "/axle"
	local manual_file = axle_dir .. "/manual_keymaps.lua"

	if vim.fn.filereadable(manual_file) == 1 then
		local ok, saved_keymaps = pcall(dofile, manual_file)
		if ok and saved_keymaps then
			-- Validate loaded keymaps for duplicates
			local valid_keymaps = {}
			local conflicts = {}

			for _, km in ipairs(saved_keymaps) do
				local exists, source, existing_desc = M.keymap_exists(km.mode, km.key)
				if not exists then
					table.insert(valid_keymaps, km)
				else
					table.insert(conflicts, { km, source, existing_desc })
				end
			end

			M.manual_keymaps = valid_keymaps

			if #conflicts > 0 then
				vim.notify(
					string.format("Loaded %d manual keymaps (%d conflicts ignored)", #valid_keymaps, #conflicts),
					vim.log.levels.WARN,
					{ title = "Axle - Load Conflicts" }
				)
			else
				vim.notify("Loaded " .. #valid_keymaps .. " manual keymaps", vim.log.levels.INFO)
			end
		end
	end
end

-- Function to show all duplicate keymaps
function M.show_duplicates()
	local file_keymaps = scanner.scan_keymaps_file()
	local all_keymaps = {}
	local duplicates = {}

	-- Add file keymaps to check list
	for _, km in ipairs(file_keymaps) do
		local key_id = km.mode .. ":" .. km.key
		if all_keymaps[key_id] then
			table.insert(duplicates, { km, all_keymaps[key_id] })
		else
			all_keymaps[key_id] = km
		end
	end

	-- Check manual keymaps against config
	for _, km in ipairs(M.manual_keymaps) do
		local key_id = km.mode .. ":" .. km.key
		if all_keymaps[key_id] then
			table.insert(duplicates, { km, all_keymaps[key_id] })
		end
	end

	if #duplicates == 0 then
		vim.notify("✓ No duplicate keymaps found!", vim.log.levels.INFO, { title = "Axle" })
		return
	end

	local lines = {}
	table.insert(lines, "⚠️  DUPLICATE KEYMAPS DETECTED:")
	table.insert(lines, "")

	for _, dup_pair in ipairs(duplicates) do
		local km1, km2 = dup_pair[1], dup_pair[2]
		table.insert(lines, string.format("[%s] %s:", km1.mode:upper(), km1.key))
		table.insert(lines, string.format("  • %s (%s)", km1.description, km1.source))
		table.insert(lines, string.format("  • %s (%s)", km2.description, km2.source))
		table.insert(lines, "")
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN, { title = "Axle - Duplicates" })
end

return M
