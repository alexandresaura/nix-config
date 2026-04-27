{ pkgs, ... }:

let
  onePassPath =
    if pkgs.stdenv.isDarwin then
      "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'"
    else
      "~/.1password/agent.sock";

  tomlFormat = pkgs.formats.toml { };
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*".identityAgent = onePassPath;

      personalgit = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/personalgit.pub";
        identitiesOnly = true;
      };

      workgit = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/workgit.pub";
        identitiesOnly = true;
      };
    };
  };

  home.file = {
    ".ssh/personalgit.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMc8iR6DQu/jJX4P6iCAv7MTY1ilQd+918smqd6LezDq\n";
    ".ssh/workgit.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMldVFujFDZwY3IwfZkPcNUyE/dB5mz+GNLbaj4a4KUL\n";

    ".config/1Password/ssh/agent.toml".source = tomlFormat.generate "1password-agent.toml" {
      ssh-keys = [
        { vault = "Personal"; }
        { vault = "Codeminer42"; }
        { vault = "GoDaddy"; }
      ];
    };
  };
}
