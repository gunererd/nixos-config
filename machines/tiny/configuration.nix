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
    ../../programs/hyprland.nix
    ../../programs/noctalia.nix
    ../../programs/alacritty.nix
    ../../programs/rustdesk.nix
    ../../programs/zed.nix
    ../../programs/helix.nix
    ../../programs/git.nix
    ../../programs/zellij.nix
    ../../programs/dolphin.nix
    ../../programs/brightnessctl.nix
    ../../programs/clipman.nix
    ../../programs/lsp.nix
    ../../programs/screenshot.nix
    ../../programs/image-viewer.nix
    ../../programs/docker.nix
    ../../programs/pdf-reader.nix
    ../../programs/archive-manager.nix
    ../../programs/dua.nix
    ../../programs/opensnitch.nix
    ../../programs/network-system-utilities.nix
    ../../programs/themes.nix
    ../../programs/icons.nix
    ../../programs/fonts.nix
    ../../programs/greetd.nix
    ../../programs/claude-code.nix
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

  networking = {
    firewall.enable = true;
    hostName = hostname;
    networkmanager = {
      enable = true;
    };
  };
  
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  hardware.acpilight.enable = true;

  # Sound settings  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    pulseaudio
  ];

  services = {
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
