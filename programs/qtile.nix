{ config, pkgs, ... }:

{
  # System-level qtile setup
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
  };
} 