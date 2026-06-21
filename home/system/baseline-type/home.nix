{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bloodhound-ce
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