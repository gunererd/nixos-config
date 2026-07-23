{ config, pkgs, ... }:

{
  # System-level zed setup
  environment.systemPackages = with pkgs; [
    opencode
  ];
} 
