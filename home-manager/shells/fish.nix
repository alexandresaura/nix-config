{ lib, dracula, ... }:
let
  hex = lib.removePrefix "#";
in
{
  programs.fish = {
    enable = true;
    shellInit = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    interactiveShellInit = ''
      fish_config theme choose "Dracula Official"
      set fish_greeting
    '';
  };

  home.file.".config/fish/themes/Dracula Official.theme".text = ''
    # Dracula Color Palette (sourced from home-manager/theme/dracula.nix)

    # Syntax Highlighting Colors
    fish_color_normal ${hex dracula.foreground}
    fish_color_command ${hex dracula.cyan}
    fish_color_keyword ${hex dracula.pink}
    fish_color_quote ${hex dracula.yellow}
    fish_color_redirection ${hex dracula.foreground}
    fish_color_end ${hex dracula.orange}
    fish_color_error ${hex dracula.red}
    fish_color_param ${hex dracula.purple}
    fish_color_comment ${hex dracula.comment}
    fish_color_selection --background=${hex dracula.selection}
    fish_color_search_match --background=${hex dracula.selection}
    fish_color_operator ${hex dracula.green}
    fish_color_escape ${hex dracula.pink}
    fish_color_autosuggestion ${hex dracula.comment}
    fish_color_cancel ${hex dracula.red} --reverse
    fish_color_option ${hex dracula.orange}
    fish_color_history_current --bold
    fish_color_status ${hex dracula.red}
    fish_color_valid_path --underline

    # Default Prompt Colors
    fish_color_cwd ${hex dracula.green}
    fish_color_cwd_root red
    fish_color_host ${hex dracula.purple}
    fish_color_host_remote ${hex dracula.purple}
    fish_color_user ${hex dracula.cyan}

    # Completion Pager Colors
    fish_pager_color_progress ${hex dracula.comment}
    fish_pager_color_background
    fish_pager_color_prefix ${hex dracula.cyan}
    fish_pager_color_completion ${hex dracula.foreground}
    fish_pager_color_description ${hex dracula.comment}
    fish_pager_color_selected_background --background=${hex dracula.selection}
    fish_pager_color_selected_prefix ${hex dracula.cyan}
    fish_pager_color_selected_completion ${hex dracula.foreground}
    fish_pager_color_selected_description ${hex dracula.comment}
    fish_pager_color_secondary_background
    fish_pager_color_secondary_prefix ${hex dracula.cyan}
    fish_pager_color_secondary_completion ${hex dracula.foreground}
    fish_pager_color_secondary_description ${hex dracula.comment}
  '';
}
