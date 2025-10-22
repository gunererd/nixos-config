{ config, pkgs, ... }:

{
  # System-level localsend setup
  environment.systemPackages = with pkgs; [
    localsend
  ];

  # Open LocalSend ports for device discovery and file transfer
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}