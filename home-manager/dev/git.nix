{ pkgs, lib, ... }:
let
  onePassSign =
    if pkgs.stdenv.isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
in
{
  programs.git = {
    enable = true;
    userName = "Alexandre Saura";
    userEmail = "alexandresaura21@gmail.com";
    signing = {
      signByDefault = true;
    };
    ignores = [
      # macOS
      ".DS_Store"
      "._*"
      ".AppleDouble"
      ".Spotlight-V100"
      ".Trashes"

      # Editors
      ".vscode/"
      ".idea/"
      "*.swp"
      "*~"
      "\\#*\\#"
      ".\\#*"

      # Claude Code
      ".claude/settings.local.json"
      "playwright-mcp/"
    ];
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";

      fetch.prune = true;

      pull.default = "current";
      push = {
        default = "current";
        autoSetupRemote = true;
      };

      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKPrWF3O1t0epeH4hjMgyYCvDpxGc116N7awG6ywbXm";
      gpg = {
        format = "ssh";
        ssh.program = onePassSign;
      };
    };
  };
}
