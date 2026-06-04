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
    ./dev/editorconfig.nix

    ./editors/neovim.nix
  ];

  programs.home-manager.enable = true;

  home = {
    # `home.username` and `home.homeDirectory` are auto-populated by the
    # nix-darwin HM integration from `users.users.<name>.{name,home}`
    # (see home-manager/nixos/common.nix). Don't redeclare them here.
    stateVersion = "26.11";

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
      pipx
      pre-commit
      ripgrep
      statix
      tree-sitter
      wget
      yarn
    ];

    shellAliases = {
      # No `#<host>` suffix — darwin-rebuild auto-detects from the system
      # hostname (set by `networking.hostName` in darwin/default.nix).
      rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-config";

      # nginx and redis run as launchd user agents (see darwin/services/).
      # These mirror `brew services start|stop|restart` muscle memory.
      # `stop` (not `bootout`) so `start` can re-kickstart without a rebuild —
      # both services set KeepAlive.SuccessfulExit=false and exit 0 on SIGTERM,
      # so launchd leaves them stopped until we kickstart again.
      nginx-start = "launchctl kickstart gui/$(id -u)/org.nixos.nginx";
      nginx-stop = "launchctl kill SIGTERM gui/$(id -u)/org.nixos.nginx";
      nginx-restart = "launchctl kickstart -k gui/$(id -u)/org.nixos.nginx";

      redis-start = "launchctl kickstart gui/$(id -u)/org.nixos.redis";
      redis-stop = "launchctl kill SIGTERM gui/$(id -u)/org.nixos.redis";
      redis-restart = "launchctl kickstart -k gui/$(id -u)/org.nixos.redis";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      RUBY_CONFIGURE_OPTS = "CFLAGS=-I${pkgs.libyaml.dev}/include LDFLAGS=-L${pkgs.libyaml}/lib";
    };

    sessionPath = [
      "$HOME/.dotnet/tools"
    ];

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
