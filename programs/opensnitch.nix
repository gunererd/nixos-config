{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    opensnitch
    opensnitch-ui
  ];

  services.opensnitch = {
    enable = true;
  };

  # Allow OpenSnitch UI to connect to daemon
  networking.firewall.allowedTCPPorts = [ 50051 ];
}