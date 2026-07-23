{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.breeze-icons
    kdePackages.breeze
    kdePackages.kio-extras
    kdePackages.kdegraphics-thumbnailers
    kdePackages.qtstyleplugin-kvantum
    qt6Packages.qt6ct
  ];

  # Make Qt applications follow GTK theme and use dark mode
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "Breeze";
    KDE_SESSION_VERSION = "6";  # Enables dark theme for KDE 6 apps
  };
}
