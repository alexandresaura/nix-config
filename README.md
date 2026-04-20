# nix-config

Declarative macOS system configuration using [Nix flakes](https://nix.dev/concepts/flakes), [nix-darwin](https://github.com/nix-darwin/nix-darwin), and [Home Manager](https://github.com/nix-community/home-manager).

One command rebuilds the entire system: packages, apps, shell setup, terminal theming, developer tools, editor config, and macOS preferences.

## Prerequisites

- macOS on Apple Silicon (aarch64-darwin)
- [Nix](https://nixos.org/download/) with flakes enabled (the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) is recommended). Once activated this config pins the daemon to [Lix](https://lix.systems/) via `nix.package = pkgs.lix`.
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

- **Packages** &mdash; coreutils
- **Fonts** &mdash; JetBrains Mono Nerd Font
- **Shells** &mdash; bash, zsh, fish (with babelfish)
- **Nix daemon** &mdash; Lix, with automatic store optimisation, weekly GC, and `nix-community.cachix.org` as an extra binary cache
- **Homebrew** &mdash; managed declaratively with auto-update, auto-upgrade, and cleanup on activation
  - **Brews** &mdash; nginx, redis
  - **Casks** &mdash; 1Password, Arc, Bruno, Claude Code, CleanShot, Cursor, Discord, Docker Desktop, Ghostty, Insomnia, Karabiner Elements, Orion, Raycast, Spotify, VS Code
- **macOS preferences** &mdash; dark mode, dock auto-hide, Finder column view with hidden files visible, Caps Lock remapped to Control, fast key repeat, Touch ID for sudo, Stage Manager

### User Environment (Home Manager)

| Category | Tools |
|----------|-------|
| **Shells** | fish (Dracula theme), zsh (autosuggestions, syntax highlighting) |
| **Terminal** | Ghostty, Starship prompt, fzf, eza, zoxide, bat, btop |
| **Dev** | git (SSH signing via 1Password), SSH (1Password agent), 1Password shell plugins (gh), mise (erlang, node, python, ruby, rust, elixir), direnv, lazygit |
| **Editor** | Neovim (LazyVim with Dracula, 30+ extras including LSPs, copilot, claude-code) |
| **CLI tools** | awscli2, curl, fastfetch, fd, gh, jq, lazysql, libyaml, ripgrep, tree-sitter, wget, yarn |

All terminal tools share a consistent **Dracula** color theme via a single palette module at `home-manager/theme/dracula.nix`, exposed to every home-manager module as `dracula`.

## Repository Structure

```
flake.nix                  # Entrypoint: inputs, darwin config, dev shell
darwin/
  default.nix              # Networking, nix settings (Lix, optimise, caches, GC)
  homebrew.nix             # Brews and casks
  packages.nix             # System packages, fonts, shells
  macos.nix                # macOS system preferences
home-manager/
  default.nix              # User packages, aliases, session variables
  theme/dracula.nix        # Shared Dracula color palette (passed as `dracula` module arg)
  shells/                  # fish, zsh
  terminal/                # ghostty, starship, fzf, eza, zoxide, bat, btop
  dev/                     # git, ssh, mise, direnv, lazygit, 1Password shell plugins
  editors/                 # neovim
configs/nvim/              # Neovim config (symlinked to ~/.config/nvim)
wallpapers/                # Wallpaper assets deployed via home.file
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
