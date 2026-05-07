{ config, lib, ... }:
# AutoRaise — focus-follows-mouse companion to AeroSpace. -delay 1 is a
# ~50ms hover threshold (default is 5s, way too slow). Needs Accessibility
# permission once on first launch (System Settings → Privacy & Security).
let
  cfg = config.wm;
in
{
  options.wm.autoraise.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Raise the window under the cursor after a short hover delay.";
  };

  config = lib.mkIf (cfg.enable && cfg.autoraise.enable) {
    wm.stopCommands = [ "pkill -x AutoRaise 2>/dev/null" ];

    home-manager.users.${config.system.primaryUser} =
      { pkgs, ... }:
      {
        wm.aerospace.afterStartup = [
          "exec-and-forget ${pkgs.autoraise}/bin/autoraise -delay 1"
        ];
      };
  };
}
