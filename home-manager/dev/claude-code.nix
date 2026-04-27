{
  pkgs,
  lib,
  dracula,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };

  # ANSI 24-bit truecolor sequences need "R;G;B" — convert from "#rrggbb".
  hexDigit =
    c:
    {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
    }
    .${lib.toLower c};
  hexToRgb =
    hex:
    let
      h = lib.removePrefix "#" hex;
      byte = i: hexDigit (builtins.substring i 1 h) * 16 + hexDigit (builtins.substring (i + 1) 1 h);
    in
    "${toString (byte 0)};${toString (byte 2)};${toString (byte 4)}";

  statuslineTemplate = builtins.readFile ../../configs/claude/statusline.sh;
  statusline =
    lib.replaceStrings
      [
        "@DRACULA_GREEN@"
        "@DRACULA_RED@"
        "@DRACULA_YELLOW@"
        "@DRACULA_CYAN@"
        "@DRACULA_PURPLE@"
        "@DRACULA_COMMENT@"
      ]
      [
        (hexToRgb dracula.green)
        (hexToRgb dracula.red)
        (hexToRgb dracula.yellow)
        (hexToRgb dracula.cyan)
        (hexToRgb dracula.purple)
        (hexToRgb dracula.comment)
      ]
      statuslineTemplate;
in
{
  # Note: ~/.claude/settings.json is intentionally not managed by nix — Claude Code
  # rewrites it when you toggle models with /model. Make sure it contains:
  #   { "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }
  home.file = {
    ".claude/statusline.sh" = {
      executable = true;
      text = statusline;
    };

    ".claude/starship-statusline.toml".source = tomlFormat.generate "starship-statusline.toml" {
      format = "$directory$git_branch$git_status";
      directory.style = "bold ${dracula.green}";
      git_branch.style = "bold ${dracula.pink}";
      git_status.style = "bold ${dracula.red}";
    };
  };
}
