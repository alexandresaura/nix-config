{ config, lib, ... }:
# JankyBorders — Dracula-coloured outline around the focused window.
# AeroSpace has no native focus border; this fills the gap. Spawned by
# AeroSpace via `wm.aerospace.afterStartup`.
let
  cfg = config.wm;
in
{
  options.wm.borders.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Draw a Dracula-purple outline around the focused window.";
  };

  config = lib.mkIf (cfg.enable && cfg.borders.enable) {
    wm.stopCommands = [ "pkill -x borders 2>/dev/null" ];

    home-manager.users.${config.system.primaryUser} =
      {
        lib,
        pkgs,
        dracula,
        ...
      }:
      let
        hex = c: lib.removePrefix "#" c;
        cmd = lib.concatStringsSep " " [
          "${pkgs.jankyborders}/bin/borders"
          "style=round"
          "width=4.0"
          "hidpi=on"
          "active_color=0xff${hex dracula.purple}"
          "inactive_color=0xff${hex dracula.selection}"
        ];
      in
      {
        wm.aerospace.afterStartup = [ "exec-and-forget ${cmd}" ];
      };
  };
}
