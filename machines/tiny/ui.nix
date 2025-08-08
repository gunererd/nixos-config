{ config, pkgs, lib, ... }:

{
  # GTK and cursor theme configuration (HOW to use themes)
  environment.sessionVariables = {
    # Cursor theme and size for tiny
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24"; # Standard cursor size for tiny
    XCURSOR_PATH = lib.mkForce "${pkgs.bibata-cursors}/share/icons";
    
    # GTK theme defaults
    GTK_THEME = "Adwaita:dark";
  };

  # X11 resources for cursor consistency across all applications
  # This ensures Firefox, Qt apps, and other non-GTK apps use the correct cursor
  environment.etc."X11/Xresources".text = ''
    Xcursor.theme: Bibata-Modern-Classic
    Xcursor.size: 24
  '';

  # System-wide GTK configuration for tiny
  environment.etc = {
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Adwaita
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-cursor-theme-size=24
      gtk-application-prefer-dark-theme=true
    '';
    
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Adwaita
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-cursor-theme-size=24
      gtk-application-prefer-dark-theme=true
    '';
  };
}