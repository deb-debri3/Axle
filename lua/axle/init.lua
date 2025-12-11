-- Axle - Keymap Browser Plugin
-- A clean, organized way to browse and search your Neovim keymaps

local M = {}
local km_ui = require("axle.ui_core")

-- Setup function to initialize the plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Add some example manual keymaps if requested
  if opts.add_examples then
    km_ui.add_keymap("n", "<leader>bb", "Buffers")
    km_ui.add_keymap("n", "<leader>tt", "Open Terminal")
  end
  
  -- Main keymap to show all keymaps with search
  vim.keymap.set("n", "<leader>mb", km_ui.show, { desc = "Axle: Browse keymaps" })
  
  -- Quick search keymap
  vim.keymap.set("n", "<leader>mbs", function()
    vim.ui.input({ prompt = "Search keymaps: " }, function(input)
      if input and input ~= "" then
        km_ui.quick_search(input)
      end
    end)
  end, { desc = "Axle: Quick search" })
  
  -- Add keymap interactively
  vim.keymap.set("n", "<leader>mba", km_ui.add_keymap_interactive, { desc = "Axle: Add keymap" })
  
  -- Save/Load manual keymaps
  vim.keymap.set("n", "<leader>mbS", km_ui.save_manual_keymaps, { desc = "Axle: Save keymaps" })
  vim.keymap.set("n", "<leader>mbL", km_ui.load_manual_keymaps, { desc = "Axle: Load keymaps" })
  
  -- Check for duplicates
  vim.keymap.set("n", "<leader>mbd", km_ui.show_duplicates, { desc = "Axle: Show duplicates" })
  
  -- Reload keymaps (useful for development)
  vim.keymap.set("n", "<leader>mbr", function()
    package.loaded["axle.keymap_scanner"] = nil
    package.loaded["axle.ui_core"] = nil
    vim.notify("Axle plugin reloaded!", vim.log.levels.INFO)
  end, { desc = "Axle: Reload plugin" })
  
  -- Auto-load manual keymaps on startup
  km_ui.load_manual_keymaps()
end

-- Auto-setup if no explicit setup is called
M.setup()

return M
