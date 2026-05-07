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

- **darwin/** — system-level:
  - `default.nix` — nix daemon (Lix), substituters, GC, networking
  - `homebrew.nix` — taps, brews, casks
  - `packages.nix` — coreutils, fonts, shells
  - `macos.nix` — system preferences across dock (incl. hot corners), trackpad (click/drag/gestures), Finder, menu-bar clock, Control Center pins, NSGlobalDomain (autocorrect, animations, save/print dialogs, locale, scrollers), WindowManager (incl. Stage Manager off), spaces (one per display), screencapture, screensaver, ActivityMonitor, login window, and Touch ID + Apple Watch for sudo. Untyped keys live in `system.defaults.CustomUserPreferences` (see *Patterns to Know*).
  - `services/` — `launchd.user.agents` for nginx and redis
  - `wm/` — AeroSpace + JankyBorders + AutoRaise stack (see *WM stack* below)
- **home-manager/** — user-level, organized by category:
  - `theme/` — shared color palettes (currently `dracula.nix`) exposed to every module via `_module.args`
  - `shells/` — fish, zsh
  - `terminal/` — ghostty, tmux, starship, fzf, eza, zoxide, bat, btop
  - `dev/` — git, ssh, mise, direnv, lazygit, 1Password shell plugins (`onepassword.nix`), Claude Code statusline (`claude-code.nix`), editorconfig (`editorconfig.nix`)
  - `editors/` — neovim (thin wrapper; actual config lives in `configs/nvim/`)

**configs/nvim/** contains a LazyVim-based Neovim setup with Lua files, symlinked into `~/.config/nvim` via `home.file`.

**configs/claude/statusline.sh** is a Dracula-palette-aware bash status line for Claude Code, rendered by `home-manager/dev/claude-code.nix`: `@DRACULA_*@` placeholders are replaced at eval time with `R;G;B` triples derived from `home-manager/theme/dracula.nix` (via a small `hexToRgb` helper in the module). The result is symlinked to `~/.claude/statusline.sh` and uses Starship (`~/.claude/starship-statusline.toml`, also rendered from the palette) for the directory/git segment. **`~/.claude/settings.json` is intentionally not managed** — Claude Code rewrites it on `/model` changes; it just needs to point at the script with `{ "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }`.

### WM stack (`darwin/wm/`)

Single tree owning AeroSpace (tiling), JankyBorders (focus outline), and AutoRaise (focus-follows-mouse). Each helper lives in its own sibling file. The shape:

- `default.nix` — declares the master option `wm.enable` (default `true`) and imports the helpers. When `wm.enable = false`, brew zaps the AeroSpace cask, no `aerospace.toml` is generated, helper packages drop out of the closure, the `wm-*` aliases disappear, and the macOS defaults in `macos-defaults.nix` flip to their native values (Sequoia edge-drag tiling back on, Spaces recency reordering back on, Mission Control flat grid back on).
- `aerospace/` — installs the brew cask (`nikitabobko/tap/aerospace`) and renders `~/.config/aerospace/aerospace.toml` from `aerospace/config.nix` (pure data) via `pkgs.formats.toml.generate`. Exposes a HM-side option **`wm.aerospace.afterStartup`** (list of strings) — helpers register `exec-and-forget …` lines into it, and the module splices the resulting list into the TOML's `after-startup-command`.
- `borders.nix` — adds JankyBorders (`pkgs.jankyborders`, Dracula-purple active / Dracula-selection inactive, rounded, 4px). Toggle with `wm.borders.enable`.
- `autoraise.nix` — adds AutoRaise (`pkgs.autoraise -delay 1`, ~50ms hover). Toggle with `wm.autoraise.enable`. Needs Accessibility permission once on first launch (System Settings → Privacy & Security → Accessibility).
- `aliases.nix` — `wm-{start,stop,restart}` shell aliases. `wm-stop` is built from **`wm.stopCommands`** (a `listOf str` declared in `darwin/wm/default.nix`); each helper appends its own pkill/killall line, joined with `; ` and tail-padded with `true` so the alias always exits 0.
- `macos-defaults.nix` — macOS system defaults that AeroSpace assumes/requires (Sequoia native tiling via `WindowManager.EnableTiling*`, `dock.mru-spaces`, `dock.expose-group-apps`). **Toggle-driven**, not `mkIf`-gated: each value is computed as `!cfg.enable` or `cfg.enable` so every rebuild writes the appropriate state (AeroSpace-friendly when on, macOS-native when off). nix-darwin only writes defaults, never deletes them, so this pattern guarantees deterministic transitions when flipping `wm.enable` — without `defaults delete` cleanup or stale plist values. Personal-pref toggles whose value is the same regardless of `wm.enable` (Stage Manager off, one Space per display) live in `darwin/macos.nix` instead.

When adding a new helper: drop a `darwin/wm/<name>.nix`, declare `options.wm.<name>.enable`, gate the body on `cfg.enable && cfg.<name>.enable`, contribute its launch command to `wm.aerospace.afterStartup` (HM-side) and its teardown to `wm.stopCommands` (system-side), then add the import to `darwin/wm/default.nix`.

## Patterns to Know

- Dracula color theme is applied consistently across fish, ghostty, tmux (via `tmux-powerkit` with `@powerkit_theme = "dracula"` and `@powerkit_theme_variant = "dark"`), starship, fzf, bat, btop, lazygit, JankyBorders, and the Claude Code statusline. The palette lives in `home-manager/theme/dracula.nix` and is passed to every module as the `dracula` arg — always reference `dracula.purple`, `dracula.background`, etc. instead of hardcoding hex. Use `lib.removePrefix "#"` when a tool needs bare hex; for ANSI 24-bit truecolor sequences (`\033[38;2;R;G;Bm`), see the `hexToRgb` helper in `home-manager/dev/claude-code.nix`.
- Shell integrations (bash, zsh, fish) are enabled in parallel for tools like fzf, zoxide, eza, starship. Fish is forced as the shell in both Ghostty (`command = "${pkgs.fish}/bin/fish"`) and tmux panes (`default-command`); avoid hardcoding paths like `/etc/profiles/...` — use `${pkgs.fish}/bin/fish` so the store path is captured.
- 1Password is the central secrets/signing backend (SSH agent, git commit signing). HTTPS git auth on `github.com` is delegated to `gh auth git-credential` (configured in `home-manager/dev/git.nix`); the global `credential.helper` is cleared so the system keychain helper does not interfere.
- `vim-tmux-navigator` provides seamless `Ctrl-h/j/k/l` movement between tmux panes and Neovim splits — wired up in both `home-manager/terminal/tmux.nix` (plugin) and `configs/nvim/lua/plugins/tmux.lua` (Neovim plugin spec). Keep both sides in sync.
- Ghostty inherits the working directory only on splits (`split-inherit-working-directory = true`); new tabs and windows start at `$HOME`. tmux mirrors this — splits and popups inherit the current pane's `cwd`, but `prefix t` opens a new window at `$HOME`.
- Each tool gets its own `.nix` file — follow this pattern when adding new modules.
- `specialArgs = { inherit inputs pkgs; }` passes flake inputs and pkgs to darwin modules. Home-manager modules receive `inputs` via `extraSpecialArgs` and pkgs via `useGlobalPkgs = true`. Use `inputs.<flake>.packages.${pkgs.stdenv.hostPlatform.system}.default` to consume packages from non-nixpkgs flake inputs (see how `tmux-powerkit` is wired in `home-manager/terminal/tmux.nix`).
- AeroSpace is the source of truth for window-manager helper lifecycle. Helpers don't run as their own launchd agents — they're spawned via AeroSpace's `after-startup-command` (see `wm.aerospace.afterStartup` in `darwin/wm/aerospace/default.nix`). This keeps everything tied to one process: `wm-stop` kills the lot, `wm-start` reopens AeroSpace which respawns helpers, and a `reload-config` in service mode re-runs the startup commands. AutoRaise used to be its own `launchd.user.agent` and logged to `/tmp/autoraise.{log,err.log}` — that's gone; helper output now flows through AeroSpace's own logs.
- AeroSpace is installed via the `nikitabobko/tap` Homebrew cask (upstream's recommended channel — the cask script strips `com.apple.quarantine` and gets autoupdates outside of `rebuild`). The TOML is generated from Nix and dropped at `~/.config/aerospace/aerospace.toml` via `home.file`. Auto-start is handled by AeroSpace itself (`start-at-login = true`) — we deliberately do **not** use home-manager's `programs.aerospace` module because it couples its launchd agent to a non-null `cfg.package`, which would conflict with the brew install. Alt+1..5 are reserved for workspaces; don't bind these in tmux/terminal/nvim. Alt-h/j/k/l drive AeroSpace focus — Ctrl-h/j/k/l stays with `vim-tmux-navigator`.
- Touch ID + Apple Watch for sudo (`security.pam.services.sudo_local.{touchIdAuth,watchIdAuth}`) are enabled **without** `reattach`. The `reattach` flag is named like a fix but is a footgun on this setup: with `reattach = true`, opening a *new* terminal session after the first one breaks Touch ID / Apple Watch sudo (the helper gets re-attached to the wrong session). Leave `reattach` off — neither will work inside tmux/screen, but they work reliably everywhere else, which is the trade we want.
- nginx and redis are nix packages (not brews) that run as `launchd.user.agent`s defined in `darwin/services/`. Both use `KeepAlive.SuccessfulExit = false` so a graceful SIGTERM (exit 0) leaves them stopped; the `{nginx,redis}-{start,stop,restart}` aliases in `home-manager/default.nix` are built on this. The stop aliases use `launchctl kill TERM gui/<uid>/<label>` — **not** `launchctl stop`, which silently fails with exit 3 against a gui-domain target (it expects a bare legacy label). Do **not** use `launchctl bootout` either — it unloads the service entirely and `kickstart` can no longer find it until the next `rebuild`. External config files live at `~/.config/{nginx,redis}/` (the repo is for *installing* tools, not committing their configs — nginx's main conf may contain work-specific server blocks).
- mise is the source of truth for language runtimes **and** for a few language-specific CLIs that need to track project versions (ruby-lsp, erb-formatter, erb_lint via the `gem:` backend; aws-okta-processor via `pipx:`). `auto_install = true` and `trusted_config_paths = [ "~/dev" ]` mean mise will pull missing tool versions on demand inside trusted dirs. When wiring a Neovim formatter/linter for one of these tools, invoke it via `mise exec -- <tool>` (see `configs/nvim/lua/plugins/ruby.lua` for the conform.nvim / nvim-lint pattern) and **strip the tool from `mason.ensure_installed`** so we don't install it twice. `pipx` is a top-level package (`home-manager/default.nix`) because mise's pipx backend shells out to it.
- Project-local `mise.toml` files are gitignored globally (`home-manager/dev/git.nix`) — they're per-machine pins, not source of truth for the project.
- macOS defaults that nix-darwin hasn't typed yet go in `system.defaults.CustomUserPreferences."<domain>" = { Key = value; }` — that's the escape hatch for raw `defaults write` semantics with no type checking. Currently used for `com.apple.{trackpad,mouse}.linear` (Sonoma-era pointer-acceleration toggles) and `com.apple.desktopservices.{DSDontWriteNetworkStores,DSDontWriteUSBStores}` (suppress `.DS_Store` on network/USB). When `nix flake check` errors with `option ... does not exist`, check `nix-darwin/modules/system/defaults/` source — if the key really isn't typed, move it to `CustomUserPreferences`.
- nix-darwin only ever calls `defaults write` — never `defaults delete`. So a `lib.mkIf cfg.enable { system.defaults.x.y = false; }` block leaves `y = false` in the plist when `cfg.enable` flips off; macOS keeps the value forever. When a setting needs to *toggle* between two states based on a flag (rather than "apply when on, do nothing when off"), write both states explicitly via `!cfg.enable` / `cfg.enable` arithmetic — see `darwin/wm/macos-defaults.nix`. The pattern always writes a value, just a different one based on the toggle, ensuring deterministic transitions without `defaults delete` cleanup.
- Many `system.defaults.*` entries in `darwin/macos.nix` are deliberately pinned at the macOS default value (trackpad gesture toggles, `spaces.spans-displays`, `WindowManager.GloballyEnabled`, etc.). They are **explicit locks**, not redundant: nix-darwin only writes defaults, never deletes, so re-asserting the default on every rebuild guarantees the value can't drift if it gets flipped via System Settings. Treat any `system.defaults.*` entry as intentional — don't strip it because "it matches the default."
- Three-finger drag (`trackpad.TrackpadThreeFingerDrag = true`) captures the 3-finger horizontal swipe gesture, so workspace navigation moves to 4 fingers via `TrackpadFourFingerHorizSwipeGesture = 2` (otherwise no trackpad gesture switches Spaces). Don't disable that without re-enabling the 3-finger swipe.
