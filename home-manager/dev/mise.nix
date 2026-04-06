{
  programs.mise = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    globalConfig = {
      settings.idiomatic_version_file_enable_tools = [
        "node"
        "ruby"
      ];
      tools = {
        erlang = "latest";
        node = "latest";
        python = "latest";
        ruby = "latest";
        rust = "latest";
        elixir = "latest";
      };
    };
  };
}
