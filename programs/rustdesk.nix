{ config, pkgs, ... }:

{
  # System-level rustdesk setup
  environment.systemPackages = with pkgs; [
    rustdesk
  ];
} 