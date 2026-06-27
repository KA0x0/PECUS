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
    sleuthkit
    sqruff
    tombi
    ty
    vue-language-server
    watchman
    waydroid
    wl-clipboard-rs
  ];
}