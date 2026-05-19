{ pkgs, ... }:

{
  home.packages = with pkgs; [
    impacket
  ];
}