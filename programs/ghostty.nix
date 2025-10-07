{ config, pkgs, ... }:

{
  # System-level ghostty installation
  environment.systemPackages = with pkgs; [
    ghostty
  ];
}