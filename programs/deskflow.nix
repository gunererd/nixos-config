{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    deskflow
  ];
}
