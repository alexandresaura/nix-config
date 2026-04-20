{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      coreutils
    ];
    pathsToLink = [ "/Applications" ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs = {
    bash.enable = true;
    zsh.enable = true;
    fish = {
      enable = true;
      useBabelfish = true;
    };
  };

  environment.shells = with pkgs; [
    bash
    zsh
    fish
  ];
}
