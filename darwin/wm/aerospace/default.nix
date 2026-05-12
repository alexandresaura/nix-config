{ config, lib, ... }:
# AeroSpace: brew cask + rendered aerospace.toml. The `after-startup-command`
# field of the TOML is built from `wm.aerospace.afterStartup` (declared
# below in the home-manager submodule), which helper modules contribute to.
let
  cfg = config.wm;
in
{
  config = lib.mkIf cfg.enable {
    homebrew = {
      taps = [ "nikitabobko/tap" ];
      casks = [ "nikitabobko/tap/aerospace" ];
    };

    wm.stopCommands = [ "killall AeroSpace 2>/dev/null" ];

    home-manager.users.${config.system.primaryUser} =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options.wm.aerospace.afterStartup = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = ''
            Commands fed verbatim into AeroSpace's after-startup-command.
            Helper modules (borders, autoraise, …) append entries here.
            Each entry should already include its own `exec-and-forget`
            (or other) prefix so we don't lock helpers into one strategy.
          '';
        };

        config = {
          home.file.".config/aerospace/aerospace.toml".source =
            (pkgs.formats.toml { }).generate "aerospace.toml"
              (
                (import ./config.nix)
                // {
                  after-startup-command = config.wm.aerospace.afterStartup;
                }
              );
        };
      };
  };
}
