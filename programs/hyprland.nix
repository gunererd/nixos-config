{ config, pkgs, ... }:

{
  # Hyprland Wayland session. Runs alongside qtile (X11) — SDDM lists both,
  # so qtile stays available as a fallback while migrating.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # let existing X11 apps run under Hyprland
  };
}
