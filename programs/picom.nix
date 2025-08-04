{ config, pkgs, ... }:

{
  # System-level picom setup
  services.picom = {
    enable = true;
    package = pkgs.picom;
    backend = "glx";
    fade = true;
    settings = {
      inactive-dim = 0.3;
      inactive-dim-fixed = true;
    };
  };

} 