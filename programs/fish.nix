{ config, pkgs, ... }:

{
  # System-level fish setup
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
  users.defaultUserShell = pkgs.fish;
} 