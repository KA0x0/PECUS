{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave-origin
    doxx
    eca
    impacket
    netexec
    rizin
    rizin-ghidra
    rz-pipe
    xleak
  ];
}