{ config, pkgs, ... }:

let
  sddm-astronaut-japanese = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;  # X11 for now
    package = pkgs.kdePackages.sddm;  # Qt6 version
    
    # Modern astronaut theme with Japanese aesthetic
    theme = "sddm-astronaut-theme";
    
    # Fix QtMultimedia runtime dependency
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      qt6.qtmultimedia
    ];
    
    settings = {
      General = {
        Numlock = "none";
        HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
        RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
      };
    };
  };

  # Japanese aesthetic astronaut theme
  environment.systemPackages = with pkgs; [
    sddm-astronaut-japanese
    qt6.qtsvg
    qt6.qtdeclarative
  ];
}