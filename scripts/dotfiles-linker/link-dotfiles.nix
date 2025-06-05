{ config, pkgs, ... }:

{
  system.activationScripts.linkDotfiles = {
    text = ''
      ${pkgs.bash}/bin/bash ${./link-dotfiles.sh} ${config.networking.hostName} hippo
    '';
    deps = [];
  };
}