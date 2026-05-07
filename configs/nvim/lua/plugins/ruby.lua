return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          cmd = { "mise", "exec", "--", "ruby-lsp" },
          mason = false,
          on_new_config = function(config, root_dir)
            local lockfile = root_dir .. "/Gemfile.lock"
            if vim.uv.fs_stat(lockfile) then
              for _, line in ipairs(vim.fn.readfile(lockfile)) do
                if line:match("ruby%-lsp") then
                  config.cmd = { "mise", "exec", "--", "bundle", "exec", "ruby-lsp" }
                  return
                end
              end
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
          prepend_args = { "exec", "--", "bundle", "exec", "rubocop" },
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
