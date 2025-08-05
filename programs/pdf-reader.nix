{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zathura  # Minimalist PDF reader
  ];
  
  # Set zathura as default PDF reader
  xdg.mime.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };
}