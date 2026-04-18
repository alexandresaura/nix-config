{ dracula, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [
          dracula.pink
          "bold"
        ];
        inactiveBorderColor = [ dracula.purple ];
        searchingActiveBorderColor = [
          dracula.cyan
          "bold"
        ];
        optionsTextColor = [ dracula.comment ];
        selectedLineBgColor = [ dracula.currentLine ];
        inactiveViewSelectedLineBgColor = [ "bold" ];
        cherryPickedCommitFgColor = [ dracula.comment ];
        cherryPickedCommitBgColor = [ dracula.cyan ];
        markedBaseCommitFgColor = [ dracula.cyan ];
        markedBaseCommitBgColor = [ dracula.yellow ];
        unstagedChangesColor = [ dracula.red ];
        defaultFgColor = [ dracula.foreground ];
      };
    };
  };
}
