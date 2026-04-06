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
      font-family = "FiraCode Nerd Font";
      font-size = 14;
      font-thicken = true;

      # Cursor
      cursor-style = "bar";
      cursor-style-blink = true;

      # Window
      window-padding-x = 10;
      window-padding-y = 10;
      window-padding-balance = true;
      window-padding-color = "background";
      window-save-state = "never";
      window-inherit-working-directory = true;

      # macOS
      macos-option-as-alt = true;
      macos-titlebar-style = "transparent";
      macos-window-shadow = true;

      # Shell
      command = "/etc/profiles/per-user/alexandre/bin/fish";

      # Behavior
      clipboard-trim-trailing-spaces = true;
      scrollback-limit = 10000000;
      link-url = true;

      # Splits
      unfocused-split-opacity = 0.85;
    };

    themes = {
      dracula = {
        background = "282a36";
        foreground = "f8f8f2";
        cursor-color = "f8f8f2";
        cursor-text = "282a36";
        palette = [
          "0=#21222c"
          "1=#ff5555"
          "2=#50fa7b"
          "3=#f1fa8c"
          "4=#bd93f9"
          "5=#ff79c6"
          "6=#8be9fd"
          "7=#f8f8f2"
          "8=#6272a4"
          "9=#ff6e6e"
          "10=#69ff94"
          "11=#ffffa5"
          "12=#d6acff"
          "13=#ff92df"
          "14=#a4ffff"
          "15=#ffffff"
        ];
        selection-background = "44475a";
        selection-foreground = "f8f8f2";
      };
    };
  };
}
