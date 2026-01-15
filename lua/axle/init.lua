-- Axle - Keymap Browser Plugin
-- A clean, organized way to browse and search your Neovim keymaps

local M = {}
local km_ui = require("axle.ui_core")

-- Setup function to initialize the plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Initialize persistence system (baseline tracking)
  km_ui.initialize()
  
  -- Store custom keymap paths if provided
  if opts.keymap_paths then
    local scanner = require("axle.keymap_scanner")
    scanner.set_custom_paths(opts.keymap_paths)
  end
  
  -- Add some example manual keymaps if requested
  if opts.add_examples then
    km_ui.add_keymap("n", "<leader>bb", "Buffers")
    km_ui.add_keymap("n", "<leader>tt", "Open Terminal")
  end
  
  -- Quick search keymap
  vim.keymap.set("n", "<leader>mbs", function()
    vim.ui.input({ prompt = "Search keymaps: " }, function(input)
      if input and input ~= "" then
        km_ui.quick_search(input)
      end
    end)
  end, { desc = "Axle: Quick search" })
  
  -- Add keymap interactively
  vim.keymap.set("n", "<leader>mba", km_ui.add_keymap_interactive, { desc = "Axle: Add manual keymap" })
  
  -- Edit manual keymap interactively
  vim.keymap.set("n", "<leader>mbe", km_ui.edit_keymap_interactive, { desc = "Axle: Edit manual keymap" })
  
  -- Remove manual keymap interactively
  vim.keymap.set("n", "<leader>mbd", km_ui.remove_keymap_interactive, { desc = "Axle: Delete manual keymap" })
  
  -- Show help panel
  vim.keymap.set("n", "<leader>mbh", km_ui.show_help, { desc = "Axle: Show help" })
  
  -- Show statistics/info
  vim.keymap.set("n", "<leader>mbi", km_ui.show_info, { desc = "Axle: Show info" })
  
  -- Save manual keymaps
  vim.keymap.set("n", "<leader>mbS", km_ui.save_manual_keymaps, { desc = "Axle: Save manual keymaps" })
  
  -- Load and browse all keymaps
  vim.keymap.set("n", "<leader>mbl", km_ui.show, { desc = "Axle: Browse keymaps" })
  
  -- Reload and rescan keymaps
  vim.keymap.set("n", "<leader>mbr", function()
    package.loaded["axle.keymap_scanner"] = nil
    package.loaded["axle.storage"] = nil
    package.loaded["axle.ui_core"] = nil
    
    -- Reload modules
    km_ui = require("axle.ui_core")
    
    -- Rescan and update auto keymaps
    km_ui.rescan_and_update()
  end, { desc = "Axle: Reload & rescan" })
  
  -- Create Vim commands
  vim.api.nvim_create_user_command("Axle", function()
    km_ui.show()
  end, { desc = "Axle: Browse all keymaps" })
  
  vim.api.nvim_create_user_command("AxleAdd", function()
    km_ui.add_keymap_interactive()
  end, { desc = "Axle: Add manual keymap" })
  
  vim.api.nvim_create_user_command("AxleEdit", function()
    km_ui.edit_keymap_interactive()
  end, { desc = "Axle: Edit manual keymap" })
  
  vim.api.nvim_create_user_command("AxleDelete", function()
    km_ui.remove_keymap_interactive()
  end, { desc = "Axle: Delete manual keymap" })
  
  vim.api.nvim_create_user_command("AxleInfo", function()
    km_ui.show_info()
  end, { desc = "Axle: Show statistics" })
  
  vim.api.nvim_create_user_command("AxleSync", function()
    package.loaded["axle.keymap_scanner"] = nil
    package.loaded["axle.storage"] = nil
    package.loaded["axle.ui_core"] = nil
    km_ui = require("axle.ui_core")
    km_ui.rescan_and_update()
  end, { desc = "Axle: Rescan & sync" })
  
  vim.api.nvim_create_user_command("AxleHelp", function()
    km_ui.show_help()
  end, { desc = "Axle: Show help" })
  
end

-- Auto-setup if no explicit setup is called
M.setup()

return M
