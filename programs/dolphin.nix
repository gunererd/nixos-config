{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libsForQt5.dolphin
    libsForQt5.breeze-icons
    libsForQt5.kio-extras
    libsForQt5.kdegraphics-thumbnailers
  ];
} 
