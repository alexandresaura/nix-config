# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Nix flake-based macOS system configuration for a single host (`Alexandre-MacBook`, aarch64-darwin). It uses **nix-darwin** for system-level config and **home-manager** (integrated as a darwin module) for user environment.

## Key Commands

```bash
# Apply the full system configuration
rebuild
# (alias for: sudo darwin-rebuild switch --flake ~/.config/nix-config)

# Enter dev shell with nixfmt-rfc-style and statix
nix develop

# Format all Nix files
nix run nixpkgs#nixfmt-tree

# Lint Nix files
nix run nixpkgs#statix -- check

# Validate the flake evaluates correctly
nix flake check

# Build the system config without applying
nix build .#darwinConfigurations.Alexandre-MacBook.system
```

Pre-commit hooks run automatically: trailing whitespace, nixfmt, statix lint, flake check.

## Architecture

**flake.nix** is the entrypoint. It defines one `darwinConfigurations` and a `devShells` output. Home-manager is wired in as a darwin module (not standalone).

Modules are split into two trees:

- **darwin/** — system-level: homebrew casks/brews (`homebrew.nix`), system packages and shells (`packages.nix`), macOS preferences (`macos.nix`), core nix/networking settings (`default.nix`)
- **home-manager/** — user-level, organized by category:
  - `shells/` — fish, zsh
  - `terminal/` — ghostty, starship, fzf, eza, zoxide
  - `dev/` — git, ssh, mise, direnv
  - `editors/` — neovim (thin wrapper; actual config lives in `configs/nvim/`)

**configs/nvim/** contains a LazyVim-based Neovim setup with Lua files, symlinked into `~/.config/nvim` via `home.file`.

## Patterns to Know

- Dracula color theme is applied consistently across fish, ghostty, starship, and fzf. Maintain this when adding new tools.
- Shell integrations (bash, zsh, fish) are enabled in parallel for tools like fzf, zoxide, eza, starship.
- 1Password is the central secrets/signing backend (SSH agent, git commit signing).
- Each tool gets its own `.nix` file — follow this pattern when adding new modules.
- `specialArgs = { inherit inputs pkgs; }` passes flake inputs and pkgs to all modules.
