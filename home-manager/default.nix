{ pkgs, ... }:
{
  imports = [
    ./theme/dracula.nix

    ./shells/fish.nix
    ./shells/zsh.nix

    ./terminal/ghostty.nix
    ./terminal/starship.nix
    ./terminal/fzf.nix
    ./terminal/eza.nix
    ./terminal/zoxide.nix
    ./terminal/bat.nix

    ./dev/git.nix
    ./dev/ssh.nix
    ./dev/mise.nix
    ./dev/direnv.nix
    ./dev/lazygit.nix

    ./editors/neovim.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "alexandre";
    homeDirectory = "/Users/alexandre";
    stateVersion = "25.11";

    packages = with pkgs; [
      fd
      gh
      jq
      nixfmt
      pre-commit
      ripgrep
      statix
      tree
    ];

    shellAliases = {
      rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-config#Alexandre-MacBook";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    file = {
      ".config/nvim" = {
        source = ../configs/nvim;
        recursive = true;
      };
      ".hushlogin" = {
        text = "";
      };
      "Pictures/Wallpapers/dracula-mountain.png" = {
        source = ../wallpapers/dracula-mountain.png;
      };
    };
  };
}
