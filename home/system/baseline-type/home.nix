{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave-origin
    impacket
  ];
}