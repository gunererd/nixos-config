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
    ../../programs/firefox.nix
    ../../programs/zen-browser.nix
    ../../programs/default.nix
    ../../programs/qtile.nix
    ../../programs/alacritty.nix
    ../../programs/ghostty.nix
    ../../programs/rofi.nix
    # ../../programs/rustdesk.nix
    ../../programs/zed.nix
    ../../programs/helix.nix
    ../../programs/picom.nix
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
    ../../programs/sddm.nix
    ../../programs/betterlockscreen.nix
    ../../programs/opensnitch.nix
    ../../programs/network-system-utilities.nix
    ../../programs/dunst.nix
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
    QT_SCALE_FACTOR = "1";
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    XCURSOR_SIZE = "48";
  };

  # Sound settings  
  services.pipewire.enable = false;
  services.pulseaudio.enable = true;

  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  systemd.user.services.spice-vdagent = {
    description = "SPICE user agent";
    wantedBy = [ "graphical-session.target" ];
    partOf   = [ "graphical-session.target" ];
    after    = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
      Restart = "on-failure";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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
    xserver = {
      enable = true;
      dpi = 144;
      # xkb.options = "altwin:swap_lalt_lwin,ctrl:swapcaps"; 
      displayManager.sessionCommands = ''
      xrandr --output Virtual-1 --mode 3840x2160
      xrdb -merge /etc/X11/Xresources  # Load cursor theme for all X11 apps
      xset r rate 200 35 &
      greenclip daemon &
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
