{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    clipman
    wl-clipboard  # Wayland clipboard utilities
    xclip         # X11 clipboard utilities
    copyq         # Better X11 clipboard manager
    haskellPackages.greenclip  # Lightweight rofi clipboard manager
  ];
}