{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    maim  # Screenshot tool for X11
    slop  # Area selection tool for X11
    xclip # For copying screenshots to clipboard
  ];
}