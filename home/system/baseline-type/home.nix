{ pkgs, ... }:

{
  home.packages = with pkgs; [
    apktool
    bloodhound-ce
    brave-origin
    eca
    frida
    ghidra
    impacket
    intermodal
    jqfmt
    mission-planner
    mitmproxy
    netexec
    powershell
    rizin-ghidra
    rz-pipe
    sleuthkit
    sqruff
    ty
    watchman
    waydroid
    wl-clipboard-rs
    yamlfmt
  ];
}