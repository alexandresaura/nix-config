{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [ "theboredteam/boring-notch" ];

    brews = [ ];

    casks = [
      "1password"
      "arc"
      "boring-notch"
      "bruno"
      "claude"
      "claude-code"
      "cleanshot"
      "cursor"
      "discord"
      "docker-desktop"
      "ghostty"
      "raycast"
      "spotify"
      "ticktick"
      "visual-studio-code"
    ];
  };
}
