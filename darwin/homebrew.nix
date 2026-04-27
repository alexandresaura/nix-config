{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      "nikitabobko/tap"
    ];

    brews = [ ];

    casks = [
      "1password"
      "nikitabobko/tap/aerospace"
      "arc"
      "bruno"
      "claude"
      "claude-code"
      "cleanshot"
      "cursor"
      "discord"
      "docker-desktop"
      "ghostty"
      "insomnia"
      "orion"
      "raycast"
      "spotify"
      "ticktick"
      "visual-studio-code"
    ];
  };
}
