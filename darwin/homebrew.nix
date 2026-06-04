{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
      # Homebrew 5.x gates `bundle install --cleanup` behind a confirmation
      # flag; nix-darwin doesn't pass it yet (upstream PR #1789, unmerged).
      extraFlags = [ "--force-cleanup" ];
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
