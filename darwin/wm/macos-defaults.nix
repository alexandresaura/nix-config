{ config, ... }:
# macOS system defaults that AeroSpace requires (or strongly prefers).
# Driven by `wm.enable`: when the master switch is on, AeroSpace-friendly
# values are written; when off, macOS-native values are written. Each
# rebuild overwrites the plist either way, so flipping `wm.enable`
# transitions cleanly without `defaults delete` or manual cleanup.
let
  cfg = config.wm;
in
{
  config = {
    system.defaults = {
      WindowManager = {
        EnableTilingByEdgeDrag = !cfg.enable;
        EnableTopTilingByEdgeDrag = !cfg.enable;
        EnableTilingOptionAccelerator = !cfg.enable;
        EnableTiledWindowMargins = !cfg.enable;
      };

      dock = {
        mru-spaces = !cfg.enable;
        expose-group-apps = cfg.enable;
      };
    };
  };
}
