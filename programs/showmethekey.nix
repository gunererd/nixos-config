{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    showmethekey    # On-screen keystroke display
  ];
}
