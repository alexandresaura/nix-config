{ dracula, ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      aws.style = "bold ${dracula.orange}";
      cmd_duration.style = "bold ${dracula.yellow}";
      directory.style = "bold ${dracula.green}";
      hostname.style = "bold ${dracula.red}";
      git_branch.style = "bold ${dracula.pink}";
      git_status.style = "bold ${dracula.red}";
      username = {
        format = "[$user]($style) on ";
        style_user = "bold ${dracula.purple}";
      };
      character = {
        success_symbol = "[λ](bold ${dracula.foreground})";
        error_symbol = "[λ](bold ${dracula.red})";
      };
    };
  };
}
