{
  environment.systemPath = [ "/opt/homebrew/bin" ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [
      "awscli"
      "nginx"
      "redis"
      "yarn"
      "libyaml"
      "tree-sitter-cli"
    ];

    casks = [
      "1password"
      "arc"
      "bruno"
      "claude-code"
      "cleanshot"
      "cursor"
      "dbeaver-community"
      "devtoys"
      "discord"
      "docker-desktop"
      "ghostty"
      "insomnia"
      "karabiner-elements"
      "ngrok"
      "raycast"
      "spotify"
      "visual-studio-code"
      "warp"
    ];
  };
}
