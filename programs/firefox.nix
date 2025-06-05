{ config, pkgs, ... }:

{
  # System-level firefox installation
  environment.systemPackages = with pkgs; [
    firefox
  ];
} 