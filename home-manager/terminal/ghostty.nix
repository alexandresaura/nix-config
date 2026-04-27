{
  pkgs,
  lib,
  dracula,
  ...
}:
let
  # Ghostty's non-palette theme fields want bare hex (no leading #).
  hex = lib.removePrefix "#";
in
{
  programs.ghostty = {
    enable = true;
    package = null;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      # Theme
      theme = "dracula";

      # Font
      font-family = "JetBrainsMono Nerd Font";
      font-thicken = true;

      # Cursor
      cursor-style = "bar";
      cursor-style-blink = true;

      # Window
      window-padding-x = 8;
      window-padding-y = 8;
      window-padding-balance = true;
      window-padding-color = "background";
      window-save-state = "never";

      # macOS
      macos-option-as-alt = true;
      macos-titlebar-style = "transparent";
      macos-window-shadow = true;

      # Shell
      command = "${pkgs.fish}/bin/fish";

      # Behavior
      clipboard-trim-trailing-spaces = true;
      scrollback-limit = 10000000;
      link-url = true;

      # Splits / tabs / windows working directory behaviour
      split-inherit-working-directory = true;
      tab-inherit-working-directory = false;
      window-inherit-working-directory = false;
      unfocused-split-opacity = 0.85;
    };

    themes = {
      dracula = {
        background = hex dracula.background;
        foreground = hex dracula.foreground;
        cursor-color = hex dracula.foreground;
        cursor-text = hex dracula.background;
        palette = [
          "0=#21222c"
          "1=${dracula.red}"
          "2=${dracula.green}"
          "3=${dracula.yellow}"
          "4=${dracula.purple}"
          "5=${dracula.pink}"
          "6=${dracula.cyan}"
          "7=${dracula.foreground}"
          "8=${dracula.comment}"
          "9=#ff6e6e"
          "10=#69ff94"
          "11=#ffffa5"
          "12=#d6acff"
          "13=#ff92df"
          "14=#a4ffff"
          "15=#ffffff"
        ];
        selection-background = hex dracula.selection;
        selection-foreground = hex dracula.foreground;
      };
    };
  };
}
