{ config, pkgs, ... }:

{
  # System-level alacritty installation
  environment.systemPackages = with pkgs; [
    alacritty
  ];
} 