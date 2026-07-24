{ config, pkgs, ... }:

{
  # GTK theme packages (WHAT to install)
  environment.systemPackages = with pkgs; [
    # GTK themes
    gnome-themes-extra  # includes Adwaita
    arc-theme
    materia-theme
    numix-gtk-theme
    whitesur-gtk-theme

    # Qt theming
    kdePackages.breeze                 # Breeze Qt style
    kdePackages.breeze-icons
    kdePackages.qtstyleplugin-kvantum
    qt6Packages.qt6ct
  ];

  # Make Qt applications follow the dark Breeze theme
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "Breeze";
    KDE_SESSION_VERSION = "6";
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    }];
  };
}