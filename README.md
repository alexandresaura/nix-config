# nix-config

Declarative macOS system configuration using [Nix flakes](https://nix.dev/concepts/flakes), [nix-darwin](https://github.com/nix-darwin/nix-darwin), and [Home Manager](https://github.com/nix-community/home-manager).

One command rebuilds the entire system: packages, apps, shell setup, terminal theming, developer tools, editor config, window manager, and macOS preferences.

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
  - **Casks**:
    - *Browsers* &mdash; Arc, Orion
    - *Dev & AI* &mdash; Bruno, Claude (Desktop), Claude Code, Cursor, Docker Desktop, Ghostty, Insomnia, VS Code
    - *Utilities* &mdash; 1Password, CleanShot, Raycast, TickTick
    - *Communication & media* &mdash; Discord, Spotify
  - **Window manager taps/casks** are added by the WM module (below) when `wm.enable = true`.
- **Window manager** (`darwin/wm/`) &mdash; AeroSpace + JankyBorders + AutoRaise, gated behind a single `wm.enable` master switch with per-helper toggles (`wm.borders.enable`, `wm.autoraise.enable`).
  - **AeroSpace** &mdash; tiling WM, installed via the `nikitabobko/tap` Homebrew cask, configured from Nix (the TOML is rendered with `pkgs.formats.toml` and dropped at `~/.config/aerospace/aerospace.toml`). Alt-h/j/k/l focus, Alt-shift-h/j/k/l move, Alt-1..5 workspaces, service mode on Alt-shift-;.
  - **JankyBorders** &mdash; Dracula-purple outline around the focused window (rounded, 4 px), spawned by AeroSpace's `after-startup-command`.
  - **AutoRaise** &mdash; focus-follows-mouse companion (`-delay 1`, ~50 ms hover threshold), also spawned by AeroSpace. Needs Accessibility permission once on first launch.
  - **`wm-{start,stop,restart}` aliases** &mdash; manage the whole stack at once.
- **Background services** (launchd user agents under `darwin/services/`)
  - **nginx**, **redis** &mdash; installed as Nix packages, started at login. Config files stay outside the repo at `~/.config/{nginx,redis}/`. Manage with the `nginx-{start,stop,restart}` / `redis-{start,stop,restart}` shell aliases.
- **macOS preferences** (`darwin/macos.nix`) &mdash; extensively customized: dark mode; dock auto-hide + `static-only` (Raycast launches, dock shows only running apps); trackpad with tap-to-click, three-finger drag, no pointer acceleration, fast cursor; Finder list view with hidden files, search-current-folder default, POSIX path in title, no extension-change warning; autocorrect / smart quotes / inline prediction off; save and print dialogs default-expanded, new docs save locally (not iCloud); 24-hour metric locale with day-of-week menu-bar clock; Control Center pins (battery %, BT, sound, Now Playing); Activity Monitor opens main window sorted by CPU; screensaver password lock immediate; bottom-right hot corner = Lock Screen; Guest login disabled; macOS auto-install off; `LSQuarantine` off (no "downloaded from the internet" prompt); no `.DS_Store` on network/USB; screenshots to `~/Pictures/Screenshots`; Caps Lock remapped to Control; fast key repeat; Touch ID + Apple Watch for sudo; Stage Manager off; one Space per display. AeroSpace-specific defaults (Sequoia edge-drag tiling, `mru-spaces`, `expose-group-apps`) live in `darwin/wm/macos-defaults.nix`, **driven by `wm.enable`** — values toggle between AeroSpace-friendly and macOS-native on each rebuild, no manual cleanup.

### User Environment (Home Manager)

| Category | Tools |
|----------|-------|
| **Shells** | fish (Dracula theme), zsh (autosuggestions, syntax highlighting) |
| **Terminal** | Ghostty, tmux (powerkit + Dracula, vim-tmux-navigator, resurrect/continuum), Starship prompt, fzf, eza, zoxide (aliased to `cd`), bat, btop |
| **Dev** | git (SSH signing via 1Password, gh credential helper for github.com), SSH (1Password agent), 1Password shell plugins (gh), mise (erlang, node, python, ruby, rust, elixir, plus `gem:`/`pipx:` backend installs for ruby-lsp, erb-formatter, erb_lint, aws-okta-processor), direnv, lazygit, Claude Code (Dracula statusline with starship + jq), EditorConfig (global `~/.editorconfig`) |
| **Editor** | Neovim (LazyVim with Dracula, 30+ extras including LSPs, copilot, claude-code, vim-tmux-navigator; Ruby/ERB tooling routed through `mise exec`) |
| **CLI tools** | awscli2, curl, fastfetch, fd, gh, gitleaks, jq, lazysql, libyaml, pipx, ripgrep, tree-sitter, wget, yarn |

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
2. In `darwin/default.nix`, update the `let username = "alexandre"` binding at the top and `networking.{hostName,computerName}` &mdash; everything else flows from there (`home-manager/default.nix` does not need touching; `home.username` and `home.homeDirectory` are auto-derived from the darwin user)
3. Update git user and SSH keys in `home-manager/dev/git.nix` and `home-manager/dev/ssh.nix`
4. Edit the Homebrew casks in `darwin/homebrew.nix` to match your preferred apps
5. Toggle the WM stack with `wm.enable` in `darwin/default.nix`, or disable individual helpers (`wm.borders.enable`, `wm.autoraise.enable`)
6. Run `rebuild`
