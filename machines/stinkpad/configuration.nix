{ config, pkgs, lib, ... }:

let
  username = "hippo";
  hostname = "stinkpad";
  stateVersion = "25.05";
in

{
  imports = [
    ./hardware-configuration.nix
    ../../programs/fish.nix
    ../../programs/firefox.nix
    ../../programs/zen-browser.nix
    ../../programs/default.nix
    ../../programs/hyprland.nix
    ../../programs/noctalia.nix
    ../../programs/alacritty.nix
    ../../programs/ghostty.nix
    ../../programs/rustdesk.nix
    ../../programs/zed.nix
    ../../programs/blueman.nix
    ../../programs/helix.nix
    ../../programs/git.nix
    ../../programs/zellij.nix
    ../../programs/dolphin.nix
    ../../programs/brightnessctl.nix
    ../../programs/claude-code.nix
    ../../programs/clipman.nix
    ../../programs/lsp.nix
    ../../programs/screenshot.nix
    ../../programs/image-viewer.nix
    ../../programs/docker.nix
    ../../programs/pdf-reader.nix
    ../../programs/archive-manager.nix
    ../../programs/dua.nix
    ../../programs/themes.nix
    ../../programs/icons.nix
    ../../programs/fonts.nix
    ../../programs/greetd.nix
    ../../programs/opensnitch.nix
    ../../programs/network-system-utilities.nix
    ../../programs/beekeeper-studio.nix
    ../../programs/opencode.nix
    ./ui.nix
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

  nix.settings = {
    experimental-features = [
      "nix-command" "flakes"
    ];
  };

  networking = {
    firewall.enable = true;
    hostName = hostname;
    networkmanager = {
      enable = true;
    };
  };
  
  environment.sessionVariables = {
    QT_SCALE_FACTOR = "1";
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    XCURSOR_SIZE = "48";
  };

  hardware.acpilight.enable = true;



  # Sound settings  
  services.pipewire.enable = false;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    pulseaudio
  ];



  services = {
    blueman.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    acpid.enable = true;
  };

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };

  # Time zone configuration
  time.timeZone = "Europe/Istanbul";

} 
