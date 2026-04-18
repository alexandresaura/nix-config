{ pkgs, ... }:
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

  system = {
    stateVersion = 6;
    primaryUser = "alexandre";
  };

  users.users.alexandre = {
    name = "alexandre";
    home = "/Users/alexandre";
  };

  nix = {
    enable = true;
    package = pkgs.lix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "@admin"
        "alexandre"
      ];
      extra-substituters = [ "https://nix-community.cachix.org" ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    optimise.automatic = true;
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
