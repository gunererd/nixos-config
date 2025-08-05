{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libsForQt5.dolphin
    libsForQt5.breeze-icons
    libsForQt5.breeze-qt5  # Dark theme support
    libsForQt5.kio-extras
    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];

  # Make Qt applications follow GTK theme and use dark mode
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "Breeze";
    KDE_SESSION_VERSION = "5";  # Enables dark theme for KDE apps
  };
} 
