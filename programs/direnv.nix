{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    direnv
  ];
} 
