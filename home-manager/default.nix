{ pkgs, ... }:
{
  imports = [
    ./shells/fish.nix
    ./shells/zsh.nix

    ./terminal/ghostty.nix
    ./terminal/starship.nix
    ./terminal/fzf.nix
    ./terminal/eza.nix
    ./terminal/zoxide.nix

    ./dev/git.nix
    ./dev/ssh.nix
    ./dev/mise.nix
    ./dev/direnv.nix

    ./editors/neovim.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "alexandre";
    homeDirectory = "/Users/alexandre";
    stateVersion = "25.11";

    packages = with pkgs; [
      bat
      fd
      gh
      jq
      lazygit
      nixfmt
      pre-commit
      ripgrep
      statix
      tmux
      tree
    ];

    shellAliases = {
      rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-config";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERM = "xterm-256color";
    };

    file = {
      ".config/nvim" = {
        source = ../configs/nvim;
        recursive = true;
      };
      ".hushlogin" = {
        text = "";
      };
    };
  };
}
