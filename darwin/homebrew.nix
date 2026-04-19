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
      "dbeaver-community"
      "discord"
      "docker-desktop"
      "ghostty"
      "insomnia"
      "karabiner-elements"
      "ngrok"
      "orion"
      "raycast"
      "spotify"
      "visual-studio-code"
    ];
  };
}
