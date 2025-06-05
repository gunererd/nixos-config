{ config, pkgs, ... }:

{
  # System-level picom setup
  services.picom = {
    enable = true;
    package = pkgs.picom;
    backend = "glx";
    fade = true;
  };

} 