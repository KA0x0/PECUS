{ pkgs, ... }:

{
  home.packages = with pkgs; [
    angr
    brave-origin
    eca
    frida
    ghidra
    impacket
    intermodal
    mitmproxy
    netexec
    powershell
    rizin-ghidra
    rz-pipe
  ];
}