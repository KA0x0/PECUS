{ pkgs, ... }:

{
  home.packages = with pkgs; [
    apktool
    bloodhound-ce
    brave-origin
    buf
    eca
    frida
    ghidra
    impacket
    intermodal
    jq-lsp
    mission-planner
    mitmproxy
    netexec
    powershell
    rizin-ghidra
    rz-pipe
    ruff
    sleuthkit
    sqruff
    tombi
    ty
    watchman
    waydroid
    wl-clipboard-rs
  ];
}