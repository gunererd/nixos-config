{ config, pkgs, ... }:

{
  # Enable git system-wide
  programs.git = {
    enable = true;
    package = pkgs.git;
    
    # Global git configuration
    config = {
      init = {
        defaultBranch = "main";
      };
      user = {
        name = "erdem";
        email = "gunererd@gmail.com";
      };
    };
  };
  
  # Add git to system packages
  environment.systemPackages = with pkgs; [
    git
    git-lfs
  ];
} 