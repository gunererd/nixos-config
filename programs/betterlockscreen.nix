{ config, pkgs, ... }:

{
  # Install i3lock-fancy for live desktop blur
  environment.systemPackages = with pkgs; [
    i3lock-fancy
    i3lock-color  # Required dependency
    imagemagick   # For blur processing
    scrot         # For screenshots
  ];

  programs.i3lock.enable = true;
}