{ config, pkgs, ... }:

{
  # System-level dunst and libnotify installation
  environment.systemPackages = with pkgs; [
    dunst
    libnotify
  ];

  # User service for dunst
  systemd.user.services.dunst = {
    description = "Dunst notification daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.dunst}/bin/dunst";
      Restart = "on-failure";
      RestartSec = 1;
    };

    environment = {
      DISPLAY = ":0";
    };
  };
}