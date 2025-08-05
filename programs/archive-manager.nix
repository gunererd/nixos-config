{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.ark  # KDE archive manager (Qt 6)
  ];
  
  # Set ark as default archive manager
  xdg.mime.defaultApplications = {
    "application/zip" = "org.kde.ark.desktop";
    "application/x-tar" = "org.kde.ark.desktop";
    "application/x-compressed-tar" = "org.kde.ark.desktop";
    "application/x-bzip-compressed-tar" = "org.kde.ark.desktop";
    "application/x-xz-compressed-tar" = "org.kde.ark.desktop";
    "application/x-rar" = "org.kde.ark.desktop";
    "application/x-7z-compressed" = "org.kde.ark.desktop";
  };
}