{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
    '';
  };

  programs.starship.enable = true;

  # Optional: set fish as the default shell
  users.defaultUserShell = pkgs.fish;
  environment.shells = [ pkgs.fish ];
}
