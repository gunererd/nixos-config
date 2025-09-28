{ config, pkgs, inputs, ... }:

{
  # System-level zen-browser installation
  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
}