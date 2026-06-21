{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
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