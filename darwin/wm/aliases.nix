{ config, lib, ... }:
# Stack-wide aliases. Mirrors the nginx/redis-{start,stop,restart} pattern
# in home-manager/default.nix. `wm-stop` is built from `wm.stopCommands`
# (see ./default.nix); each helper module appends its own teardown line
# when enabled, so disabling a helper automatically drops it from wm-stop.
let
  cfg = config.wm;
  stopCmd = lib.concatStringsSep "; " (cfg.stopCommands ++ [ "true" ]);
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.system.primaryUser} = {
      home.shellAliases = {
        wm-stop = stopCmd;
        wm-start = "open -a AeroSpace";
        wm-restart = "wm-stop; sleep 0.3; wm-start";
      };
    };
  };
}
