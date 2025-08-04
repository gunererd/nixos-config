{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    imv    # Image viewer for X11 and Wayland
  ];

  # Set imv as default image viewer
  xdg.mime.defaultApplications = {
    "image/jpeg" = "imv.desktop";
    "image/jpg" = "imv.desktop";
    "image/png" = "imv.desktop";
    "image/gif" = "imv.desktop";
    "image/webp" = "imv.desktop";
    "image/tiff" = "imv.desktop";
    "image/bmp" = "imv.desktop";
    "image/svg+xml" = "imv.desktop";
  };
}
