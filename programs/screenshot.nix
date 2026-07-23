{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xclip # For copying screenshots to clipboard
    grim  # Screenshot tool for Wayland (Hyprland)
    slurp # Area selection tool for Wayland (Hyprland)
  ];
}