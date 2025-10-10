{ config, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.caskaydia-mono
      monaspace
      hack-font
      mononoki
      agave
      ibm-plex
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "PragmataPro" "IBM Plex Serif" ];
        sansSerif = [ "PragmataPro" "IBM Plex Sans" ];
        monospace = [ "PragmataPro Mono" "IBM Plex Mono" "FiraCode Nerd Font" "Fira Code" ];
      };
    };
  };
}