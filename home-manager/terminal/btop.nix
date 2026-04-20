{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dracula";
    };
  };

  home.file.".config/btop/themes/dracula.theme".source =
    "${pkgs.btop}/share/btop/themes/dracula.theme";
}
