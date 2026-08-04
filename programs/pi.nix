{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pi-coding-agent
  ];
}
