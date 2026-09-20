{ pkgs, ... }:

{
  home.packages = with pkgs; [
    agent-browser
    apktool
    bloodhound-ce
    brave-origin
    buf
    codeql
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
    turso
    ty
    vue-language-server
    wasm-tools
    watchman
    waydroid
    weave
    wl-clipboard-rs
    xdebug
    yaml-language-server
  ];
}