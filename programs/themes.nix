{ config, pkgs, ... }:

{
  # GTK theme packages (WHAT to install)
  environment.systemPackages = with pkgs; [
    # GTK themes
    gnome-themes-extra  # includes Adwaita
    arc-theme
    materia-theme
    numix-gtk-theme
  ];

  # Enable dconf for GTK settings
  programs.dconf.enable = true;
}