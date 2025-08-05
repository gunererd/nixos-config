{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Icon themes
    papirus-icon-theme
    tela-icon-theme
    numix-icon-theme
    adwaita-icon-theme
    hicolor-icon-theme
    whitesur-icon-theme
    
    # Icon fonts
    font-awesome
    material-design-icons
    material-symbols
    
    # Cursor themes
    vanilla-dmz
    capitaine-cursors
    bibata-cursors
    whitesur-cursors
  ];

}