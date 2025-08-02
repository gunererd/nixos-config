{ config, pkgs, ... }:

{
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
  users.defaultUserShell = pkgs.fish;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
}
