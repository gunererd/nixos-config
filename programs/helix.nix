{ config, pkgs, ... }:

{
  # System-level helix setup
  environment.systemPackages = with pkgs; [
    helix
  ];
} 