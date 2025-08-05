{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dua  # Disk usage analyzer
  ];
}