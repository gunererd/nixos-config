{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libsForQt5.dolphin
    libsForQt5.breeze-icons
    libsForQt5.kio-extras
    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];

  # Make Qt applications follow GTK theme
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
} 
