{ dracula, ... }:
{
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    colors = {
      fg = dracula.foreground;
      bg = dracula.background;
      hl = dracula.purple;
      "fg+" = dracula.foreground;
      "bg+" = dracula.selection;
      "hl+" = dracula.purple;
      info = dracula.orange;
      prompt = dracula.green;
      pointer = dracula.pink;
      marker = dracula.pink;
      spinner = dracula.orange;
      header = dracula.currentLine;
    };
  };
}
