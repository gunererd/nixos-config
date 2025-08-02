{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    atuin
  ];
} 
