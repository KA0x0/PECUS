{ pkgs, ... }:

{
  home.packages = with pkgs; [
    angr
    brave-origin
    doxx
    eca
    ghidra
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