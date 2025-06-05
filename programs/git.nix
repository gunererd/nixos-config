{ config, pkgs, ... }:

{
  # Enable git system-wide
  programs.git = {
    enable = true;
    package = pkgs.git;
  };
  
  # Add git to system packages
  environment.systemPackages = with pkgs; [
    git
    git-lfs
  ];
} 