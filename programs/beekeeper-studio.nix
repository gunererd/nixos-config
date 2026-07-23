{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    beekeeper-studio
  ];
}