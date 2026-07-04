{ pkgs, ... }:
{
  home.packages = with pkgs; [
    typescript-language-server
    typescript
    pyright
    lua-language-server
    ruby-lsp
  ];
}
