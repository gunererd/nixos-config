{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    herdr-desktop
  ];
}
