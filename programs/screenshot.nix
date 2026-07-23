{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    maim  # Screenshot tool for X11 (qtile)
    slop  # Area selection tool for X11 (qtile)
    xclip # For copying screenshots to clipboard
    grim  # Screenshot tool for Wayland (Hyprland)
    slurp # Area selection tool for Wayland (Hyprland)
  ];
}