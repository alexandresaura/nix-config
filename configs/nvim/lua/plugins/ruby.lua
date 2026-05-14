local function gem_bundled(lockfile, pattern)
  if not lockfile or not vim.uv.fs_stat(lockfile) then
    return false
  end
  for _, line in ipairs(vim.fn.readfile(lockfile)) do
    if line:match(pattern) then
      return true
    end
  end
  return false
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          cmd = { "mise", "exec", "--", "ruby-lsp" },
          mason = false,
          on_new_config = function(config, root_dir)
            if gem_bundled(root_dir .. "/Gemfile.lock", "ruby%-lsp") then
              config.cmd = { "mise", "exec", "--", "bundle", "exec", "ruby-lsp" }
            end
          end,
        },
        rubocop = {
          enabled = false,
          mason = false,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        rubocop = {
          command = "mise",
          prepend_args = function(_, ctx)
            local lockfile = vim.fs.find("Gemfile.lock", { upward = true, path = ctx.dirname })[1]
            if gem_bundled(lockfile, "rubocop") then
              return { "exec", "--", "bundle", "exec", "rubocop" }
            end
            return { "exec", "--", "rubocop" }
          end,
        },
        erb_format = {
          command = "mise",
          prepend_args = { "exec", "--", "erb-format" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        erb_lint = {
          cmd = "mise",
          args = { "exec", "--", "erblint", "--format", "compact", "--no-color" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "erb-formatter" and tool ~= "erb-lint"
      end, opts.ensure_installed or {})
    end,
  },
}
