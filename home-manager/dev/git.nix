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
    signing = {
      signByDefault = true;
    };
    settings = {
      init.defaultBranch = "main";
      core.editor = "nvim";

      fetch.prune = true;

      pull.default = "current";
      push = {
        default = "current";
        autoSetupRemote = true;
      };

      user = {
        name = "Alexandre Saura";
        email = "alexandresaura21@gmail.com";
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKPrWF3O1t0epeH4hjMgyYCvDpxGc116N7awG6ywbXm";
      };
      gpg = {
        format = "ssh";
        ssh.program = onePassSign;
      };
      credential.helper = "";
      credential."https://github.com".helper = "!${lib.getExe pkgs.gh} auth git-credential";
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
  };
}
