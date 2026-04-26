{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [
      "nginx"
      "redis"
    ];

    casks = [
      "1password"
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
