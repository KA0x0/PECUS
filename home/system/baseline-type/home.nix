{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave-origin
    eca
    impacket
    netexec
    xleak
  ];
}