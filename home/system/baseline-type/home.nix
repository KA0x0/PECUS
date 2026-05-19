{ pkgs, ... }:

{
  home.packages = with pkgs; [
    angr
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