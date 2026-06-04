{
  programs.mise = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    globalConfig = {
      settings = {
        auto_install = true;
        trusted_config_paths = [ "~/dev" ];
        status.missing_tools = "if_other_versions_installed";
        idiomatic_version_file_enable_tools = [
          "node"
          "ruby"
        ];
      };
      tools = {
        # Language runtimes
        elixir = "latest";
        erlang = "latest";
        go = "latest";
        node = "latest";
        python = "latest";
        ruby = "latest";
        rust = "latest";

        # Backend-installed CLIs
        "gem:erb-formatter" = "latest";
        "gem:erb_lint" = "latest";
        "gem:rubocop" = "latest";
        "gem:ruby-lsp" = "latest";
        "pipx:aws-okta-processor" = "latest";
      };
    };
  };
}
