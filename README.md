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
- **Nix daemon** &mdash; Lix, with automatic store optimisation, weekly GC, and `cache.lix.systems` + `nix-community.cachix.org` as extra binary caches
- **Homebrew** &mdash; managed declaratively with auto-update, auto-upgrade, and cleanup on activation
  - **Taps** &mdash; `nikitabobko/tap` (AeroSpace)
  - **Casks**:
    - *Browsers* &mdash; Arc, Orion
    - *Dev & AI* &mdash; Bruno, Claude (Desktop), Claude Code, Cursor, Docker Desktop, Ghostty, Insomnia, VS Code
    - *Window manager* &mdash; AeroSpace (tiling WM, via the upstream tap)
    - *Utilities* &mdash; 1Password, CleanShot, Raycast, TickTick
    - *Communication & media* &mdash; Discord, Spotify
- **Background services** (launchd user agents under `darwin/services/`)
  - **nginx**, **redis** &mdash; installed as Nix packages, started at login. Config files stay outside the repo at `~/.config/{nginx,redis}/`. Manage with the `nginx-{start,stop,restart}` / `redis-{start,stop,restart}` shell aliases.
  - **AutoRaise** &mdash; focus-follows-mouse companion to AeroSpace (`-delay 1`, 50 ms hover threshold). Needs Accessibility permission once on first launch (System Settings → Privacy & Security → Accessibility).
- **macOS preferences** &mdash; dark mode, dock auto-hide, Finder column view with hidden files visible, Caps Lock remapped to Control, fast key repeat, Touch ID for sudo (with `reattach` so it survives tmux/screen), Stage Manager

### User Environment (Home Manager)

| Category | Tools |
|----------|-------|
| **Shells** | fish (Dracula theme), zsh (autosuggestions, syntax highlighting) |
| **Terminal** | Ghostty, tmux (powerkit + Dracula, vim-tmux-navigator, resurrect/continuum), Starship prompt, fzf, eza, zoxide (aliased to `cd`), bat, btop |
| **Dev** | git (SSH signing via 1Password, gh credential helper for github.com), SSH (1Password agent), 1Password shell plugins (gh), mise (erlang, node, python, ruby, rust, elixir), direnv, lazygit, Claude Code (Dracula statusline with starship + jq) |
| **Editor** | Neovim (LazyVim with Dracula, 30+ extras including LSPs, copilot, claude-code, vim-tmux-navigator) |
| **Desktop** | AeroSpace (tiling WM — Alt-h/j/k/l focus, Alt-shift-h/j/k/l move, Alt-1..9 workspaces, service mode on Alt-shift-;) |
| **CLI tools** | awscli2, curl, fastfetch, fd, gh, gitleaks, jq, lazysql, libyaml, ripgrep, tree-sitter, wget, yarn |

All terminal tools share a consistent **Dracula** color theme via a single palette module at `home-manager/theme/dracula.nix`, exposed to every home-manager module as `dracula`.

## Repository Structure

```
flake.nix                  # Entrypoint: inputs, darwin config, dev shell
darwin/
  default.nix              # Networking, nix settings (Lix, optimise, caches, GC)
  homebrew.nix             # Taps, brews, casks
  packages.nix             # System packages, fonts, shells
  macos.nix                # macOS system preferences
  services/                # launchd user agents: autoraise, nginx, redis
home-manager/
  default.nix              # User packages, aliases, session variables
  theme/dracula.nix        # Shared Dracula color palette (passed as `dracula` module arg)
  shells/                  # fish, zsh
  terminal/                # ghostty, tmux, starship, fzf, eza, zoxide, bat, btop
  dev/                     # git, ssh, mise, direnv, lazygit, 1Password shell plugins, claude-code
  editors/                 # neovim
  desktop/                 # aerospace (tiling WM, config rendered from Nix)
configs/nvim/              # Neovim config (symlinked to ~/.config/nvim)
configs/claude/            # Claude Code statusline template (palette injected at build time)
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
