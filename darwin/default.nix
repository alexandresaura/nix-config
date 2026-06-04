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
      trusted-users = [ "@admin" ];
      warn-dirty = false;
    };
    optimise = {
      automatic = true;
      interval = {
        Weekday = 2;
        Hour = 13;
        Minute = 30;
      };
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      interval = {
        Weekday = 2;
        Hour = 13;
        Minute = 0;
      };
    };
  };
}
