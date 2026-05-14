-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local fish = vim.fn.exepath("fish")
if fish ~= "" then
  vim.o.shell = fish
end
