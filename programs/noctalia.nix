{ config, pkgs, ... }:

{
  # Noctalia — Quickshell-based Wayland desktop shell (bar, launcher,
  # notifications, control center, lock, wallpaper, OSDs). Launched from
  # Hyprland via `noctalia-shell` (see dotfiles/stinkpad/hypr/hyprland.lua).
  environment.systemPackages = with pkgs; [
    noctalia-shell
  ];

  # Services Noctalia relies on. networkmanager + bluetooth are already
  # enabled in the machine config; these two are the missing pieces.
  services.upower.enable = true;              # battery info
  services.power-profiles-daemon.enable = true; # power profile switching
}
