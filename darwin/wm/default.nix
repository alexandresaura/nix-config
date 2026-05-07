{ lib, ... }:
# WM stack entry point. Each app/helper lives in its own sibling file with
# its own `wm.<name>.enable` toggle. This file just owns the master switch
# and the imports list — adding a new helper is one new file plus one line
# here. AeroSpace exposes `wm.aerospace.afterStartup` (HM-side, see
# ./aerospace/default.nix); helpers contribute exec strings to that list.
{
  imports = [
    ./aerospace
    ./borders.nix
    ./autoraise.nix
    ./aliases.nix
    ./macos-defaults.nix
  ];

  options.wm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Master switch for the AeroSpace + JankyBorders + AutoRaise stack.
        When false: brew zaps the AeroSpace cask, no aerospace.toml is
        generated, helper packages drop out of the nix closure, and the
        `wm-*` aliases disappear.
      '';
    };

    stopCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Shell commands joined with `; ` into the `wm-stop` alias. Each
        helper module appends its own teardown line when enabled (e.g.
        `pkill -x borders 2>/dev/null`). Suppress no-match noise yourself
        — `wm-stop` chains a final `true` so the whole pipeline always
        exits 0.
      '';
    };
  };
}
