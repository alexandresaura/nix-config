# nix-config

Declarative macOS system configuration using [Nix flakes](https://nix.dev/concepts/flakes), [nix-darwin](https://github.com/nix-darwin/nix-darwin), and [Home Manager](https://github.com/nix-community/home-manager). One command rebuilds the entire system: packages, apps, shell, terminal theming, dev tools, editor, window manager, and macOS preferences.

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
- **Nix daemon** &mdash; Lix, with automatic store optimisation and weekly GC (uses `cache.nixos.org` only)
- **Homebrew** &mdash; managed declaratively with auto-update, auto-upgrade, and cleanup on activation
  - **Casks**:
    - _Browsers_ &mdash; Arc
    - _Dev & AI_ &mdash; Bruno, Claude (Desktop), Claude Code, Cursor, Docker Desktop, Ghostty, VS Code
    - _Utilities_ &mdash; 1Password, CleanShot, Raycast, TickTick
    - _Communication & media_ &mdash; Discord, Spotify
  - **Window manager taps/casks** are added by the WM module (below) when `wm.enable = true`.
- **Window manager** (`darwin/wm/`) &mdash; AeroSpace tiling + JankyBorders focus outline + AutoRaise focus-follows-mouse. Single `wm.enable` master switch with per-helper toggles (`wm.borders.enable`, `wm.autoraise.enable`). Alt+h/j/k/l focus, Alt+1..5 workspaces. Manage the whole stack with the `wm-{start,stop,restart}` aliases.
- **Background services** &mdash; nginx and redis run as launchd user agents (`darwin/services/`); configs live outside the repo at `~/.config/{nginx,redis}/`. Manage with `{nginx,redis}-{start,stop,restart}` aliases.
- **macOS preferences** (`darwin/macos.nix`):
  - _Appearance_ &mdash; dark mode; dock auto-hide + `static-only` (running apps only; Raycast handles launching); menu-bar clock with day of week; Stage Manager off; one Space per display
  - _Trackpad & input_ &mdash; no pointer acceleration, fast cursor; Caps Lock remapped to Control; fast key repeat
  - _Finder_ &mdash; list view with hidden files, search-current-folder default, POSIX path in title, no extension-change warning
  - _NSGlobalDomain_ &mdash; autocorrect / smart quotes / inline prediction off; save & print dialogs default-expanded; new docs save locally (not iCloud); 24-hour metric locale
  - _Control Center_ &mdash; battery %, Bluetooth pinned to menu bar
  - _Security_ &mdash; Touch ID + Apple Watch for sudo; immediate screensaver password lock; bottom-right hot corner = Lock Screen; Guest login disabled; `LSQuarantine` off
  - _Misc_ &mdash; screenshots to `~/Pictures/Screenshots`; no `.DS_Store` on network/USB; Activity Monitor sorted by CPU; macOS auto-install off
  - AeroSpace-specific defaults (Sequoia edge-drag tiling, `mru-spaces`, `expose-group-apps`) live in `darwin/wm/macos-defaults.nix` and toggle with `wm.enable`

### User Environment (Home Manager)

| Category      | Tools                                                                                                                                                                                                                                                                                                                                                                                              |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Shells**    | fish (Dracula theme), zsh (autosuggestions, syntax highlighting)                                                                                                                                                                                                                                                                                                                                   |
| **Terminal**  | Ghostty, tmux (powerkit + Dracula, vim-tmux-navigator, resurrect/continuum), Starship prompt, fzf, eza, zoxide (aliased to `cd`), bat, btop                                                                                                                                                                                                                                                        |
| **Dev**       | git (SSH signing via 1Password, gh credential helper for github.com), SSH (1Password agent), 1Password shell plugins (gh), mise (elixir, erlang, go, node, python, ruby, rust, plus `gem:`/`pipx:` backend installs for ruby-lsp, rubocop, erb-formatter, erb_lint, aws-okta-processor), direnv, lazygit, Claude Code (Dracula statusline with starship + jq), EditorConfig (global `~/.editorconfig`) |
| **Editor**    | Neovim (LazyVim with Dracula, 30+ extras including LSPs, copilot, claude-code, vim-tmux-navigator; Ruby/ERB tooling routed through `mise exec`)                                                                                                                                                                                                                                                    |
| **CLI tools** | awscli2, curl, fastfetch, fd, gh, gitleaks, jq, lazysql, libyaml, pipx, ripgrep, tree-sitter, wget, yarn                                                                                                                                                                                                                                                                                           |

All terminal tools share a consistent **Dracula** color theme via a single palette module at `home-manager/theme/dracula.nix`, exposed to every home-manager module as `dracula`.

## Repository Structure

```
flake.nix                  # Entrypoint: inputs, darwin config, dev shell
darwin/
  default.nix              # Networking, nix settings (Lix, optimise, caches, GC)
  homebrew.nix             # Taps, brews, casks (WM cask is added by wm/)
  packages.nix             # System packages, fonts, shells
  macos.nix                # macOS system preferences
  services/                # launchd user agents: nginx, redis
  wm/                      # AeroSpace + JankyBorders + AutoRaise stack
    default.nix            # Master `wm.enable` switch + imports
    aerospace/             # Brew cask + aerospace.toml renderer
    borders.nix            # JankyBorders (focus outline)
    autoraise.nix          # AutoRaise (focus-follows-mouse)
    aliases.nix            # wm-{start,stop,restart}
    macos-defaults.nix     # AeroSpace-specific macOS defaults (gated)
home-manager/
  default.nix              # User packages, aliases, session variables
  theme/dracula.nix        # Shared Dracula color palette (passed as `dracula` module arg)
  shells/                  # fish, zsh
  terminal/                # ghostty, tmux, starship, fzf, eza, zoxide, bat, btop
  dev/                     # git, ssh, mise, direnv, lazygit, 1Password shell plugins, claude-code, editorconfig
  editors/                 # neovim
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
2. In `darwin/default.nix`, update the `username` binding and `networking.{hostName,computerName}`. Home-manager auto-derives `home.username` and `home.homeDirectory` from the darwin user, so `home-manager/default.nix` doesn't need touching.
3. Update git user and SSH keys in `home-manager/dev/git.nix` and `home-manager/dev/ssh.nix`
4. Edit the Homebrew casks in `darwin/homebrew.nix` to match your preferred apps
5. Toggle the WM stack with `wm.enable` in `darwin/default.nix`, or disable individual helpers (`wm.borders.enable`, `wm.autoraise.enable`)
6. Run `rebuild`

For module conventions, option contracts, and the gotchas behind various design choices, see [CLAUDE.md](./CLAUDE.md).
