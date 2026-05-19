{ pkgs, ... }:

{
  home.packages = with pkgs; [
    angr
    brave-origin
    doxx
    eca
    impacket
    intermodal
    mitmproxy
    netexec
    powershell
    rizin
    rizin-ghidra
    rz-pipe
    xleak
  ];
}