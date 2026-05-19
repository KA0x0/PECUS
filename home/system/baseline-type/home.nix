{ pkgs, ... }:

{
  home.packages = with pkgs; [
    angr
    brave-origin
    doxx
    eca
    frida
    ghidra
    impacket
    intermodal
    mitmproxy
    netexec
    powershell
    rizin
    rizin-ghidra
    rz-pipe
    syncplay
    xleak
  ];
}