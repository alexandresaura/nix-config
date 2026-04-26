{ pkgs, inputs, ... }:
{
  imports = [
    inputs._1password-shell-plugins.hmModules.default

    ./theme/dracula.nix

    ./shells/fish.nix
    ./shells/zsh.nix

    ./terminal/ghostty.nix
    ./terminal/starship.nix
    ./terminal/fzf.nix
    ./terminal/eza.nix
    ./terminal/zoxide.nix
    ./terminal/bat.nix
    ./terminal/btop.nix
    ./terminal/tmux.nix

    ./dev/git.nix
    ./dev/ssh.nix
    ./dev/mise.nix
    ./dev/direnv.nix
    ./dev/lazygit.nix
    ./dev/onepassword.nix
    ./dev/claude-code.nix

    ./editors/neovim.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "alexandre";
    homeDirectory = "/Users/alexandre";
    stateVersion = "25.11";

    packages = with pkgs; [
      awscli2
      curl
      fastfetch
      fd
      gh
      gitleaks
      jq
      lazysql
      libyaml
      nixfmt
      pre-commit
      ripgrep
      statix
      tree-sitter
      wget
      yarn
    ];

    shellAliases = {
      rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-config#Alexandre-MacBook";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      RUBY_CONFIGURE_OPTS = "CFLAGS=-I${pkgs.libyaml.dev}/include LDFLAGS=-L${pkgs.libyaml}/lib";
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
