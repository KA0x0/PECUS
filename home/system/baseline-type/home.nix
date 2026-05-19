{ pkgs, ... }:

{
  home.packages = with pkgs; [
    angr
    brave-origin
    doxx
    eca
    impacket
    netexec
    powershell
    rizin
    rizin-ghidra
    rz-pipe
    xleak
  ];
}