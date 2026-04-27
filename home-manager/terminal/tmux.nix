{
  pkgs,
  inputs,
  dracula,
  ...
}:
{
  programs.tmux = {
    enable = true;

    prefix = "C-Space";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 10;
    focusEvents = true;
    historyLimit = 50000;
    clock24 = true;
    customPaneNavigationAndResize = true;
    disableConfirmationPrompt = true;
    resizeAmount = 10;
    sensibleOnTop = true;
    terminal = "tmux-256color";
    shell = "${pkgs.fish}/bin/fish";

    plugins = with pkgs.tmuxPlugins; [
      yank
      vim-tmux-navigator
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
      {
        plugin = inputs.tmux-powerkit.packages.${pkgs.stdenv.hostPlatform.system}.default;
        extraConfig = ''
          set -g @powerkit_theme "dracula"
          set -g @powerkit_theme_variant "dark"
          set -g @powerkit_transparent "true"
          set -g @powerkit_clock_style "24"

          set -g @powerkit_status_order "session,windows,plugins"

          set -g @powerkit_separator_style "rounded"
          set -g @powerkit_edge_separator_style "rounded:all"

          set -g @powerkit_popup_border_lines "rounded"
          set -g @powerkit_menu_border_lines "rounded"

          set -g @powerkit_plugins "git,group(cpu,memory),group(battery,datetime)"

          set -g @powerkit_keybinding_conflict_action "skip"
        '';
      }
    ];

    extraConfig = ''
      # ─── Settings ────────────────────────────────────────────────

      # Force fish in panes (sensible would otherwise default-command to /bin/zsh on macOS).
      set -g default-command "${pkgs.fish}/bin/fish -l"

      # 24-bit color (true color) for modern terminals
      set -as terminal-features ",xterm*:RGB,tmux*:RGB,*ghostty*:RGB"

      # Keep window numbers contiguous after one closes (1,3,4 -> 1,2,3)
      set -g renumber-windows on

      # Closing the last window switches to another session instead of detaching
      set -g detach-on-destroy off


      # ─── Bindings · panes & windows ──────────────────────────────
      # Note: powerkit binds `prefix r` to reload-config.

      # Splits inherit current pane's cwd. Lowercase = active pane, uppercase = whole window.
      unbind '"'
      unbind %
      bind v split-window -h  -c "#{pane_current_path}"
      bind V split-window -fh -c "#{pane_current_path}"
      bind s split-window -v  -c "#{pane_current_path}"
      bind S split-window -fv -c "#{pane_current_path}"

      # New window at $HOME (regardless of current pane's cwd)
      bind t new-window -c "$HOME"

      # Floating scratch shell at current cwd
      bind Tab display-popup -E -w 80% -h 80% -d "#{pane_current_path}" -s "bg=${dracula.background}"

      # Faster copy-mode entry than the default `[`
      bind Space copy-mode

      # Double-tap prefix to toggle last window (overrides auto-emitted send-prefix)
      bind C-Space last-window


      # ─── Bindings · session management ───────────────────────────

      bind Q confirm-before -p "kill-session #S? (y/n)" kill-session
      bind * set-window-option synchronize-panes \; display-message "sync-panes #{?pane_synchronized,on,off}"


      # ─── Bindings · copy mode (vi keys) ──────────────────────────
      # v: begin selection · C-v: toggle rectangle · y: copy and exit
      bind -T copy-mode-vi v                  send-keys -X begin-selection
      bind -T copy-mode-vi C-v                send-keys -X rectangle-toggle
      bind -T copy-mode-vi y                  send-keys -X copy-pipe-no-clear "pbcopy"
      bind -T copy-mode-vi MouseDragEnd1Pane  send-keys -X copy-pipe-no-clear "pbcopy"
    '';
  };
}
