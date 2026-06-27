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
    mago
    mission-planner
    mitmproxy
    netexec
    powershell
    responder
    rizin-ghidra
    rz-pipe
    sleuthkit
    sqruff
    tombi
    ty
    vue-language-server
    wasm-tools
    watchman
    waydroid
    wl-clipboard-rs
    xdebug
  ];
}