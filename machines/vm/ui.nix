{ config, pkgs, lib, ... }:

{
  # GTK and cursor theme configuration for desktop
  environment.sessionVariables = {
    # Cursor theme and size for desktop
    XCURSOR_THEME = "WhiteSur-cursors";
    XCURSOR_SIZE = "48";
    XCURSOR_PATH = lib.mkForce "${pkgs.whitesur-cursors}/share/icons";
    
    # GTK theme defaults
    GTK_THEME = "WhiteSur-Dark";
  };

  # System-wide GTK configuration for desktop
  environment.etc = {
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=WhiteSur-Dark
      gtk-icon-theme-name=WhiteSur-dark
      gtk-cursor-theme-name=WhiteSur-cursors
      gtk-cursor-theme-size=48
      gtk-application-prefer-dark-theme=true
    '';
    
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=WhiteSur-Dark
      gtk-icon-theme-name=WhiteSur-dark
      gtk-cursor-theme-name=WhiteSur-cursors
      gtk-cursor-theme-size=48
      gtk-application-prefer-dark-theme=true
    '';
  };
}