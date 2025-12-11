-- plugin/axle.lua
-- Auto-load Axle plugin

if vim.g.loaded_axle then
  return
end
vim.g.loaded_axle = true

-- Load the plugin
require("axle")
