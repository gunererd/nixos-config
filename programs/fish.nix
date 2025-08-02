{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    starship
  ];


  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
    '';
  };


  programs.starship.enable = true;

  users.defaultUserShell = pkgs.fish;
  environment.shells = [ pkgs.fish ];
}
