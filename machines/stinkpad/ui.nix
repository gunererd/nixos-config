{ config, pkgs, lib, ... }:

{
  # GTK and cursor theme configuration (HOW to use themes)
  environment.sessionVariables = {
    # Cursor theme and size for stinkpad
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "48"; # Larger cursor for stinkpad
    XCURSOR_PATH = lib.mkForce "${pkgs.bibata-cursors}/share/icons";
    
    # GTK theme defaults
    GTK_THEME = "Adwaita:dark";
  };

  # System-wide GTK configuration for stinkpad
  environment.etc = {
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Adwaita
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-cursor-theme-size=48
      gtk-application-prefer-dark-theme=true
    '';
    
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Adwaita
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-cursor-theme-size=48
      gtk-application-prefer-dark-theme=true
    '';
  };
}