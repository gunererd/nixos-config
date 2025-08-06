{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    opensnitch
    opensnitch-ui
    libnotify  # Fix desktop notifications
  ];

  services.opensnitch = {
    enable = true;
  };

  # Allow OpenSnitch UI to connect to daemon
  networking.firewall.allowedTCPPorts = [ 50051 ];
  
  # Enable dbus for notifications
  services.dbus.enable = true;
}