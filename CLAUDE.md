# CLAUDE.md

Guidance for Claude Code working in this repo.

**[README.md](./README.md) owns "what exists":** install steps, the catalog of what's configured, the file tree, and how to customize. Don't duplicate that here. This file documents only what's needed to change the config safely — conventions, option contracts, and invariants that aren't obvious from reading the code.

## Working in this repo

- `rebuild` reapplies the config. The user runs it themselves at the end of a change set — don't shell out to `darwin-rebuild` or `nix build` after every edit.
- `nix flake check` and `statix check` run as pre-commit hooks; the commit will fail loudly if something's off.
- All other commands (dev shell, format, lint, build-only) are in README.md.

## Conventions

- **One darwin host** (`Alexandre-MacBook`, aarch64-darwin). Home-manager is wired in as a darwin module, not standalone — there's no `home-manager switch` step.
- **Module args:** `specialArgs = { inherit inputs pkgs; }` for darwin modules; home-manager modules receive `inputs` via `extraSpecialArgs` and pkgs via `useGlobalPkgs = true`. Consume non-nixpkgs flake inputs via `inputs.<flake>.packages.${pkgs.stdenv.hostPlatform.system}.default` (see `home-manager/terminal/tmux.nix` for `tmux-powerkit`).
- **One tool per file** under the matching `home-manager/<category>/` directory (`shells/`, `terminal/`, `dev/`, `editors/`). Follow the existing pattern when adding a new tool.
- **Dracula palette** lives in `home-manager/theme/dracula.nix` and is passed to every home-manager module as the `dracula` arg via `_module.args`. Always reference `dracula.purple`, `dracula.background`, etc.; never hardcode hex. Use `lib.removePrefix "#"` when a tool needs bare hex; for ANSI 24-bit truecolor sequences (`\033[38;2;R;G;Bm`), see the `hexToRgb` helper in `home-manager/dev/claude-code.nix`.
- **`home.file` over `xdg.configFile`** when dropping `~/.config/<app>/...` files — matches the rest of the repo.
- **Reserved key bindings:** Alt+1..5 are AeroSpace workspaces; don't bind these in tmux/terminal/nvim. Alt+h/j/k/l drive AeroSpace focus. `Ctrl+h/j/k/l` belongs to `vim-tmux-navigator` (wired in both `home-manager/terminal/tmux.nix` and `configs/nvim/lua/plugins/tmux.lua` — keep both sides in sync).

## WM stack invariants (`darwin/wm/`)

README describes what the stack _does_. The contracts below are what must hold when changing it:

- **Master switch:** `wm.enable` (default `true`) gates the whole tree. Helpers gate on `cfg.enable && cfg.<name>.enable`.
- **AeroSpace owns helper lifecycle, not launchd.** Helpers are spawned via AeroSpace's `after-startup-command`. Each helper appends its launch line to the HM-side option `wm.aerospace.afterStartup` (`listOf str`) and its teardown to the system-side option `wm.stopCommands` (`listOf str`). `wm-stop` joins `stopCommands` with `;` and tail-pads with `true` so the alias always exits 0.
- **Toggle-driven macOS defaults, not `mkIf`-gated.** `darwin/wm/macos-defaults.nix` uses `cfg.enable` / `!cfg.enable` arithmetic to write both the AeroSpace-friendly and macOS-native states — see _nix-darwin only writes defaults, never deletes_ under Patterns for why. Personal-pref toggles whose value is the same regardless of `wm.enable` (Stage Manager off, one Space per display) live in `darwin/macos.nix` instead.
- **AeroSpace is brew-installed on purpose.** The `nikitabobko/tap` cask strips quarantine and autoupdates outside `rebuild`. Do **not** switch to `programs.aerospace` — its launchd agent conflicts with the brew install when `cfg.package` is non-null.
- **Adding a helper:** drop `darwin/wm/<name>.nix`, declare `options.wm.<name>.enable`, gate body on `cfg.enable && cfg.<name>.enable`, contribute launch to `wm.aerospace.afterStartup` (HM) and teardown to `wm.stopCommands` (system), then add the import to `darwin/wm/default.nix`.

## Patterns to Know

- **Claude Code statusline rendering** — `configs/claude/statusline.sh` and `~/.claude/starship-statusline.toml` are templates with `@DRACULA_*@` placeholders replaced at eval time from the palette by `home-manager/dev/claude-code.nix`. The result is symlinked to `~/.claude/`. **`~/.claude/settings.json` is intentionally unmanaged** — Claude Code rewrites it on `/model` changes; it just needs `{ "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }`.

- **Shell integrations are enabled in parallel** for bash/zsh/fish (fzf, zoxide, eza, starship). Fish is forced as the shell in both Ghostty (`command = "${pkgs.fish}/bin/fish"`) and tmux panes (`default-command`); avoid hardcoding paths like `/etc/profiles/...` — use `${pkgs.fish}/bin/fish` so the store path is captured.

- **1Password is the secrets backend** for SSH agent and git commit signing. HTTPS git auth on `github.com` is delegated to `gh auth git-credential` (see `home-manager/dev/git.nix`); the global `credential.helper` is cleared so the system keychain doesn't interfere.

- **Cwd inheritance:** Ghostty inherits cwd only on splits (`split-inherit-working-directory = true`); new tabs/windows start at `$HOME`. tmux mirrors this — splits and popups inherit cwd; `prefix t` opens a new window at `$HOME`.

- **Touch ID + Apple Watch sudo without `reattach`.** `security.pam.services.sudo_local.{touchIdAuth,watchIdAuth}` are enabled but `reattach` is left off. With `reattach = true`, opening a _new_ terminal session after the first one breaks Touch ID/Apple Watch sudo (helper gets re-attached to the wrong session). Trade: neither works inside tmux/screen, but they work reliably everywhere else.

- **nginx and redis are nix packages**, not brews — they run as `launchd.user.agent`s under `darwin/services/`. Both use `KeepAlive.SuccessfulExit = false` so a graceful SIGTERM (exit 0) leaves them stopped. The `{nginx,redis}-{start,stop,restart}` aliases use `launchctl kill TERM gui/<uid>/<label>` — **not** `launchctl stop` (silently fails with exit 3 in the gui domain), and **not** `launchctl bootout` (unloads the service entirely; `kickstart` then can't find it until next `rebuild`). External configs live at `~/.config/{nginx,redis}/`, outside this repo (nginx may have work-specific server blocks).

- **mise owns language runtimes AND a few language-specific CLIs** (rubocop, erb-formatter, erb_lint via `gem:`; aws-okta-processor via `pipx:`). `auto_install = true`, `trusted_config_paths = [ "~/dev" ]`. When wiring a Neovim formatter/linter for one of these tools, invoke via `mise exec -- <tool>` (see `configs/nvim/lua/plugins/ruby.lua`) and **strip the tool from `mason.ensure_installed`** to avoid double install. `pipx` is a top-level package because mise's pipx backend shells out to it. Language servers (including `ruby-lsp`) live in `home-manager/dev/language-servers.nix`, not mise: Claude Code's LSP plugins resolve them from the global PATH and can't invoke them through `mise exec`, so they must be installed via `home.packages`.

- **Project-local `mise.toml`** is gitignored globally (`home-manager/dev/git.nix`) — per-machine pins, not source of truth.

- **Untyped macOS defaults escape hatch:** `system.defaults.CustomUserPreferences."<domain>" = { Key = value; }` for raw `defaults write` semantics with no type checking. Currently used for `com.apple.{trackpad,mouse}.linear` (Sonoma pointer-acceleration toggles) and `com.apple.desktopservices.{DSDontWriteNetworkStores,DSDontWriteUSBStores}`. When `nix flake check` errors with `option ... does not exist`, check `nix-darwin/modules/system/defaults/` source — if the key truly isn't typed, move it to `CustomUserPreferences`.

- **nix-darwin only writes defaults, never deletes.** A `lib.mkIf cfg.enable { system.defaults.x.y = false; }` block leaves `y = false` in the plist when the flag flips off. When a setting needs to _toggle_ between two states based on a flag, write both states explicitly via `!cfg.enable` / `cfg.enable` arithmetic (see `darwin/wm/macos-defaults.nix`). The pattern always writes a value, just a different one based on the toggle — deterministic transitions without `defaults delete` cleanup.

- **Pinned-default `system.defaults.*` entries are intentional locks**, not redundant. Trackpad gesture toggles, `spaces.spans-displays`, `WindowManager.GloballyEnabled`, etc. are deliberately re-asserted at the macOS default value on every rebuild so they can't drift if flipped via System Settings. Don't strip them because "they match the default."
