{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    clipman
    wl-clipboard  # Wayland clipboard utilities (wl-paste/wl-copy)
    cliphist      # Wayland clipboard history backend for Noctalia's clipboard launcher
    xclip         # X11 clipboard utilities
    copyq         # Better X11 clipboard manager
    haskellPackages.greenclip  # Lightweight rofi clipboard manager (qtile)
  ];
}