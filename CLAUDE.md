# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Nix flake-based macOS system configuration for a single host (`Alexandre-MacBook`, aarch64-darwin). It uses **nix-darwin** for system-level config and **home-manager** (integrated as a darwin module) for user environment. The nix daemon is pinned to **Lix** via `nix.package = pkgs.lix` in `darwin/default.nix`, with `cache.lix.systems` and `nix-community.cachix.org` as substituters.

Flake inputs: `nixpkgs` (unstable), `nix-darwin`, `home-manager`, `_1password-shell-plugins`, and `tmux-powerkit` (for the tmux statusline; see `home-manager/terminal/tmux.nix`). All except `tmux-powerkit` follow the root `nixpkgs`.

## Key Commands

```bash
# Apply the full system configuration
rebuild
# (alias for: sudo darwin-rebuild switch --flake ~/.config/nix-config)

# Enter dev shell with nixfmt and statix
nix develop

# Format all Nix files (nixfmt-tree wraps pkgs.nixfmt)
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

- **darwin/** — system-level: homebrew casks and service brews (`homebrew.nix`), coreutils/fonts/shells (`packages.nix`), macOS preferences (`macos.nix`), core nix/networking settings (`default.nix`)
- **home-manager/** — user-level, organized by category:
  - `theme/` — shared color palettes (currently `dracula.nix`) exposed to every module via `_module.args`
  - `shells/` — fish, zsh
  - `terminal/` — ghostty, tmux, starship, fzf, eza, zoxide, bat, btop
  - `dev/` — git, ssh, mise, direnv, lazygit, 1Password shell plugins (`onepassword.nix`), Claude Code statusline (`claude-code.nix`)
  - `editors/` — neovim (thin wrapper; actual config lives in `configs/nvim/`)

**configs/nvim/** contains a LazyVim-based Neovim setup with Lua files, symlinked into `~/.config/nvim` via `home.file`.

**configs/claude/statusline.sh** is a Dracula-palette-aware bash status line for Claude Code, rendered by `home-manager/dev/claude-code.nix`: `@DRACULA_*@` placeholders are replaced at eval time with `R;G;B` triples derived from `home-manager/theme/dracula.nix` (via a small `hexToRgb` helper in the module). The result is symlinked to `~/.claude/statusline.sh` and uses Starship (`~/.claude/starship-statusline.toml`, also rendered from the palette) for the directory/git segment. **`~/.claude/settings.json` is intentionally not managed** — Claude Code rewrites it on `/model` changes; it just needs to point at the script with `{ "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }`.

## Patterns to Know

- Dracula color theme is applied consistently across fish, ghostty, tmux (via `tmux-powerkit` with `@powerkit_theme = "dracula"` and `@powerkit_theme_variant = "dark"`), starship, fzf, bat, btop, lazygit, and the Claude Code statusline. The palette lives in `home-manager/theme/dracula.nix` and is passed to every module as the `dracula` arg — always reference `dracula.purple`, `dracula.background`, etc. instead of hardcoding hex. Use `lib.removePrefix "#"` when a tool needs bare hex; for ANSI 24-bit truecolor sequences (`\033[38;2;R;G;Bm`), see the `hexToRgb` helper in `home-manager/dev/claude-code.nix`.
- Shell integrations (bash, zsh, fish) are enabled in parallel for tools like fzf, zoxide, eza, starship. Fish is forced as the shell in both Ghostty (`command = "${pkgs.fish}/bin/fish"`) and tmux panes (`default-command`); avoid hardcoding paths like `/etc/profiles/...` — use `${pkgs.fish}/bin/fish` so the store path is captured.
- 1Password is the central secrets/signing backend (SSH agent, git commit signing). HTTPS git auth on `github.com` is delegated to `gh auth git-credential` (configured in `home-manager/dev/git.nix`); the global `credential.helper` is cleared so the system keychain helper does not interfere.
- `vim-tmux-navigator` provides seamless `Ctrl-h/j/k/l` movement between tmux panes and Neovim splits — wired up in both `home-manager/terminal/tmux.nix` (plugin) and `configs/nvim/lua/plugins/tmux.lua` (Neovim plugin spec). Keep both sides in sync.
- Touch ID for sudo uses `security.pam.services.sudo_local.reattach = true` so it survives inside tmux/screen sessions; do not drop `reattach` if you touch that block.
- Ghostty inherits the working directory only on splits (`split-inherit-working-directory = true`); new tabs and windows start at `$HOME`. tmux mirrors this — splits and popups inherit the current pane's `cwd`, but `prefix t` opens a new window at `$HOME`.
- Each tool gets its own `.nix` file — follow this pattern when adding new modules.
- `specialArgs = { inherit inputs pkgs; }` passes flake inputs and pkgs to darwin modules. Home-manager modules receive `inputs` via `extraSpecialArgs` and pkgs via `useGlobalPkgs = true`. Use `inputs.<flake>.packages.${pkgs.stdenv.hostPlatform.system}.default` to consume packages from non-nixpkgs flake inputs (see how `tmux-powerkit` is wired in `home-manager/terminal/tmux.nix`).
