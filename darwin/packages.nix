{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      coreutils
      curl
      git
      htop
      wget
    ];
    pathsToLink = [ "/Applications" ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
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
