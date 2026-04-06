{
  imports = [
    ./homebrew.nix
    ./packages.nix
    ./macos.nix
  ];

  networking = {
    hostName = "Alexandre-MacBook";
    computerName = "Alexandre MacBook";
  };

  nix.enable = true;

  system = {
    stateVersion = 6;
    primaryUser = "alexandre";
  };

  users.users.alexandre = {
    name = "alexandre";
    home = "/Users/alexandre";
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "@admin"
        "alexandre"
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
    };
  };
}
