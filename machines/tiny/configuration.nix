{ config, pkgs, ... }:

let
  username = "hippo";
  hostname = "tiny";
  stateVersion = "25.05";
in

{
  imports = [
    ./hardware-configuration.nix
    ../../programs/fish.nix
    ../../programs/firefox.nix
    ../../programs/default.nix
    ../../programs/qtile.nix
    ../../programs/alacritty.nix
    ../../programs/rofi.nix
    ../../programs/rustdesk.nix
    ../../programs/zed.nix
    ../../programs/helix.nix
    ../../programs/picom.nix
    ../../programs/git.nix
    ../../scripts/dotfiles-linker/link-dotfiles.nix
  ];

  # Basic system setup
  users.users.hippo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system = {
    stateVersion = stateVersion;
  };

  networking = {
    firewall.enable = false;
    hostName = hostname;
    networkmanager = {
      enable = true;
    };
  };
  
  environment.sessionVariables = {
    QT_SCALE_FACTOR = "1.25";
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1.25";
  };

  hardware.acpilight.enable = true;

  services = {
    acpid.enable = true;
    xserver = {
      enable = true;
      dpi = 120;
      xkb.options = "altwin:swap_lalt_lwin,ctrl:swapcaps"; 
      displayManager.sessionCommands = ''
      xwallpaper --zoom ${../../wallpapers/eyes.png}
      xset r rate 200 35 &
    '';
    };
  };

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Time zone configuration
  time.timeZone = "Europe/Istanbul";

} 
