{ pkgs, inputs, ... }:
let
  username = "alexandre";
in
{
  imports = [
    ./homebrew.nix
    ./packages.nix
    ./macos.nix

    ./services/nginx.nix
    ./services/redis.nix

    ./wm
  ];

  # Master switch for the AeroSpace + JankyBorders + AutoRaise stack.
  wm.enable = false;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users.${username} = import ../home-manager;
  };

  networking = {
    hostName = "Alexandre-MacBook";
    computerName = "Alexandre MacBook";
  };

  system = {
    stateVersion = 6;
    primaryUser = username;
  };

  users.users.${username} = {
    # `name` defaults to the attr key in nix-darwin's users module.
    home = "/Users/${username}";
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
        username
      ];
      extra-substituters = [
        "https://cache.lix.systems"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cache.lix.systems-1:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRpIarfA="
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
