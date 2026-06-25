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
    ruff
    rz-pipe
    sleuthkit
    sqruff
    tombi
    ty
    watchman
    waydroid
    wl-clipboard-rs
  ];
}