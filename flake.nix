{
  description = "Declarative macOS system configuration with nix-darwin, home-manager, and Lix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-powerkit = {
      url = "github:fabioluciano/tmux-powerkit";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
      };
    in
    {
      darwinConfigurations."Alexandre-MacBook" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs pkgs;
        };
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixfmt
          statix
        ];
      };
    };
}
