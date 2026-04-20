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
      "claude-code"
      "cleanshot"
      "cursor"
      "discord"
      "docker-desktop"
      "ghostty"
      "insomnia"
      "karabiner-elements"
      "orion"
      "raycast"
      "spotify"
      "visual-studio-code"
    ];
  };
}
