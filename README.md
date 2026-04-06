# nix-config

Declarative macOS system configuration using [Nix flakes](https://nix.dev/concepts/flakes), [nix-darwin](https://github.com/nix-darwin/nix-darwin), and [Home Manager](https://github.com/nix-community/home-manager).

One command rebuilds the entire system: packages, apps, shell setup, terminal theming, developer tools, editor config, and macOS preferences.

## Prerequisites

- macOS on Apple Silicon (aarch64-darwin)
- [Nix](https://nixos.org/download/) with flakes enabled (the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) is recommended)
- [Homebrew](https://brew.sh/) (nix-darwin manages it declaratively, but it must be installed first)

## Getting Started

```bash
# Clone the repo
git clone https://github.com/alexandresaura/nix-config.git ~/.config/nix-config
cd ~/.config/nix-config

# Apply the full system configuration
sudo darwin-rebuild switch --flake .
```

After the first build, a shell alias is available:

```bash
rebuild   # re-applies the configuration
```

## What Gets Configured

### System (nix-darwin)

- **Packages** &mdash; coreutils, curl, git, htop, wget
- **Fonts** &mdash; Fira Code Nerd Font
- **Shells** &mdash; bash, zsh, fish (with babelfish)
- **Homebrew** &mdash; managed declaratively with auto-update, auto-upgrade, and cleanup on activation
  - **Brews** &mdash; awscli, nginx, redis, yarn, libyaml, tree-sitter-cli
  - **Casks** &mdash; 1Password, Arc, Bruno, Claude Code, CleanShot, Cursor, DBeaver, DevToys, Discord, Docker Desktop, Ghostty, Insomnia, Karabiner Elements, ngrok, Raycast, Spotify, VS Code, Warp
- **macOS preferences** &mdash; dark mode, dock auto-hide, Finder column view with hidden files visible, Caps Lock remapped to Control, fast key repeat, Touch ID for sudo, Stage Manager

### User Environment (Home Manager)

| Category | Tools |
|----------|-------|
| **Shells** | fish (Dracula theme), zsh (autosuggestions, syntax highlighting) |
| **Terminal** | Ghostty, Starship prompt, fzf, eza, zoxide |
| **Dev** | git (SSH signing via 1Password), SSH (1Password agent), mise (erlang, node, python, ruby, rust, elixir), direnv |
| **Editor** | Neovim (LazyVim with Dracula, 30+ extras including LSPs, copilot, claude-code) |
| **CLI tools** | bat, fd, gh, jq, lazygit, ripgrep, tmux, tree |

All terminal tools share a consistent **Dracula** color theme.

## Repository Structure

```
flake.nix                  # Entrypoint: inputs, darwin config, dev shell
darwin/
  default.nix              # Networking, nix settings, garbage collection
  homebrew.nix             # Brews and casks
  packages.nix             # System packages, fonts, shells
  macos.nix                # macOS system preferences
home-manager/
  default.nix              # User packages, aliases, session variables
  shells/                  # fish, zsh
  terminal/                # ghostty, starship, fzf, eza, zoxide
  dev/                     # git, ssh, mise, direnv
  editors/                 # neovim
configs/nvim/              # Neovim config (symlinked to ~/.config/nvim)
```

## Development

```bash
# Enter dev shell with formatting and linting tools
nix develop

# Format all Nix files
nix run nixpkgs#nixfmt-tree

# Lint Nix files for anti-patterns
nix run nixpkgs#statix -- check

# Validate the flake
nix flake check

# Build without applying
nix build .#darwinConfigurations.Alexandre-MacBook.system
```

Pre-commit hooks handle formatting and linting automatically on each commit.

## Customizing

To adapt this config for your own machine:

1. Replace `"Alexandre-MacBook"` in `flake.nix` with your hostname
2. Update `username`, `homeDirectory`, and networking names in `darwin/default.nix` and `home-manager/default.nix`
3. Update git user and SSH keys in `home-manager/dev/git.nix` and `home-manager/dev/ssh.nix`
4. Edit the Homebrew casks in `darwin/homebrew.nix` to match your preferred apps
5. Run `rebuild`
