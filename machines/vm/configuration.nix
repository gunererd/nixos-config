{ config, pkgs, lib, ... }:

let
  username = "hippo";
  hostname = "vm";
  stateVersion = "25.05";
in

{
  imports = [
    ./hardware-configuration.nix
    ../../programs/fish.nix
    ../../programs/zen-browser.nix
    ../../programs/default.nix
    ../../programs/hyprland.nix
    ../../programs/noctalia.nix
    ../../programs/alacritty.nix
    # ../../programs/rustdesk.nix
    ../../programs/localsend.nix
    ../../programs/zed.nix
    ../../programs/helix.nix
    ../../programs/git.nix
    ../../programs/zellij.nix
    ../../programs/nautilus.nix
    ../../programs/brightnessctl.nix
    ../../programs/claude-code.nix
    ../../programs/pi.nix
    ../../programs/omp.nix
    ../../programs/clipman.nix
    ../../programs/lsp.nix
    ../../programs/screenshot.nix
    ../../programs/image-viewer.nix
    ../../programs/showmethekey.nix
    ../../programs/docker.nix
    ../../programs/llmtrim.nix
    ../../programs/pdf-reader.nix
    ../../programs/archive-manager.nix
    ../../programs/dua.nix
    ../../programs/themes.nix
    ../../programs/icons.nix
    ../../programs/fonts.nix
    ../../programs/greetd.nix
    ../../programs/opensnitch.nix
    ../../programs/syncthing.nix
    ../../programs/network-system-utilities.nix
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
    MESA_VK_DEVICE_SELECT = "virtio";
    ZED_ALLOW_EMULATED_GPU = "1";
  };

  # Sound settings  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
    ];
  };

  environment.systemPackages = with pkgs; [
    pulseaudio
    mesa-demos
    vulkan-tools
  ];

  # systemd.user.services.spice-vdagent = {
  #   description = "SPICE guest agent (user)";
  #   after = [ "graphical-session.target"];
  #   wants = [ "graphical-session.target"];
  #   partOf = [ "graphical-session.target"];

  #   environment = {
  #     DISPLAY = ":0";
  #     XDG_SESSION_TYPE = "x11";
  #   };
    
  #   serviceConfig = {
  #     ExecStart =  "${pkgs.spice-vdagent}/bin/spice-vdagent";
  #     Type = "simple";
  #     Restart = "on-failure";
  #     RestartSec = 1;
  #     ConditionPathExists = "/dev/virtio-ports/com.redhat.spice.0";
  #   };
  #   wantedBy = [ "graphical-session.target"];
  # };


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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  

} 
