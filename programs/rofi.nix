{ config, pkgs, ... }:

{
  # System-level rofi setup
  environment.systemPackages = with pkgs; [
    rofi
  ];
} 