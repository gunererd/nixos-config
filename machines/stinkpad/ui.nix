{ config, pkgs, lib, ... }:

{
  # GTK and cursor theme configuration (HOW to use themes)
  environment.sessionVariables = {
    # Cursor theme and size for stinkpad
    XCURSOR_THEME = "WhiteSur-cursors";
    XCURSOR_SIZE = "48"; # Larger cursor for stinkpad
    XCURSOR_PATH = lib.mkForce "${pkgs.whitesur-cursors}/share/icons";
  };

  # System-wide GTK configuration for stinkpad
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