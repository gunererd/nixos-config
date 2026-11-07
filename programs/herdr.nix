{ config, pkgs, lib, ... }:

let
  herdr-desktop = pkgs.herdr-desktop.overrideAttrs (finalAttrs: prev: {
    version = "0.1.13";
    src = pkgs.fetchFromGitHub {
      owner = "herdrdev";
      repo = "herdr-app";
      tag = "v${finalAttrs.version}";
      fetchSubmodules = true;
      hash = "sha256-vM25epPf+4Y+gUj/2BTQ6fpOIBI7T5UddFdlMAr6X0o=";
    };
    cargoHash = "sha256-7bz9iEMvf2o2I0SsnXaZ0135PlMm73DrJ9ZhSqAjcKY=";
    doCheck = false;
  });
in
{
  environment.systemPackages = [
    herdr-desktop
    pkgs.python3
  ];
}
