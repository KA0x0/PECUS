{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave-origin
    doxx
    eca
    impacket
    netexec
    xleak
  ];
}