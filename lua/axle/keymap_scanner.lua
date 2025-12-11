-- Axle - Keymap Scanner Module
local M = {}

-- Function to parse keymaps from keymaps.lua file
function M.scan_keymaps_file()
  local keymaps_file = vim.fn.stdpath("config") .. "/lua/config/keymaps.lua"
  local keymaps = {}
  
  -- Check if file exists
  if vim.fn.filereadable(keymaps_file) == 0 then
    return keymaps
  end
  
  -- Read file content
  local lines = vim.fn.readfile(keymaps_file)
  
  for i, line in ipairs(lines) do
    -- Match vim.keymap.set patterns
    local mode, key, desc = line:match('keymap%.set%("([^"]+)",%s*"([^"]+)".-desc%s*=%s*"([^"]+)"')
    if mode and key and desc then
      table.insert(keymaps, {
        mode = mode,
        key = key,
        description = desc,
        line_number = i,
        source = "keymaps.lua"
      })
    end
    
    -- Match telescope_maps table entries
    local tel_key, tel_desc = line:match('%["([^"]+)"%]%s*=%s*{.-"([^"]+)"')
    if tel_key and tel_desc then
      table.insert(keymaps, {
        mode = "n",
        key = tel_key,
        description = tel_desc,
        line_number = i,
        source = "keymaps.lua (telescope_maps)"
      })
    end
    
    -- Match function-based keymaps
    local func_mode, func_key = line:match('keymap%.set%("([^"]+)",%s*"([^"]+)",%s*function%(%)') 
    if func_mode and func_key then
      -- Look for desc in the same line or next few lines
      local func_desc = "Custom function"
      local desc_match = line:match('desc%s*=%s*"([^"]+)"')
      if desc_match then
        func_desc = desc_match
      else
        -- Check next few lines for desc
        for j = i+1, math.min(i+3, #lines) do
          local next_desc = lines[j]:match('desc%s*=%s*"([^"]+)"')
          if next_desc then
            func_desc = next_desc
            break
          end
        end
      end
      
      table.insert(keymaps, {
        mode = func_mode,
        key = func_key,
        description = func_desc,
        line_number = i,
        source = "keymaps.lua"
      })
    end
    
    -- Match command-style keymaps like ":NvimTreeToggle<CR>"
    local cmd_mode, cmd_key, cmd_command = line:match('keymap%.set%("([^"]+)",%s*"([^"]+)",%s*"([^"]*)"')
    if cmd_mode and cmd_key and cmd_command and cmd_command:match("^:") then
      -- Look for desc in same line
      local cmd_desc = line:match('desc%s*=%s*"([^"]+)"')
      if not cmd_desc then
        cmd_desc = "Command: " .. cmd_command:gsub("^:", ""):gsub("<CR>$", "")
      end
      
      table.insert(keymaps, {
        mode = cmd_mode,
        key = cmd_key,
        description = cmd_desc,
        line_number = i,
        source = "keymaps.lua"
      })
    end
  end
  
  return keymaps
end

-- Function to get runtime keymaps
function M.get_runtime_keymaps()
  local keymaps = {}
  local modes = {"n", "i", "v", "x", "t", "c", "s", "o"}
  
  for _, mode in ipairs(modes) do
    local mode_keymaps = vim.api.nvim_get_keymap(mode)
    for _, keymap in ipairs(mode_keymaps) do
      if keymap.desc and keymap.desc ~= "" then
        table.insert(keymaps, {
          mode = mode,
          key = keymap.lhs,
          description = keymap.desc,
          rhs = keymap.rhs or "function",
          source = "runtime"
        })
      end
    end
  end
  
  return keymaps
end

-- Function to get keymaps from file only (no runtime)
function M.get_file_keymaps_only()
  local file_keymaps = M.scan_keymaps_file()
  
  -- Sort by mode then by key
  table.sort(file_keymaps, function(a, b)
    if a.mode == b.mode then
      return a.key < b.key
    end
    return a.mode < b.mode
  end)
  
  return file_keymaps
end

-- Keep the old function for backward compatibility but mark as deprecated
function M.get_all_keymaps()
  -- Only return file keymaps now, as requested
  return M.get_file_keymaps_only()
end

return M