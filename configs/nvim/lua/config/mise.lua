-- `mise activate` in the parent shell injects direct tool paths that go stale
-- when tool versions change. Strip those and prepend shims, which resolve
-- per-directory via .tool-versions.
local shims = vim.env.HOME .. "/.local/share/mise/shims"
local installs = vim.env.HOME .. "/.local/share/mise/installs/"
local clean = {}
for entry in vim.env.PATH:gmatch("[^:]+") do
  if entry ~= shims and entry:sub(1, #installs) ~= installs then
    clean[#clean + 1] = entry
  end
end
vim.env.PATH = shims .. ":" .. table.concat(clean, ":")
