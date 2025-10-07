{ config, pkgs, ... }:

{
  # System-level picom setup with blur
  services.picom = {
    enable = true;
    package = pkgs.picom;
    backend = "glx";
    fade = true;
    settings = {
      inactive-dim = 0.3;
      inactive-dim-fixed = true;
      
      # Blur settings
      blur = {
        method = "dual_kawase";
        strength = 3;
        background = false;
        background-frame = false;
        background-fixed = false;
      };
      
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "class_g = 'slop'"
      ];
    };
  };

} 
