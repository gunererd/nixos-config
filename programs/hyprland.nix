{ config, pkgs, ... }:

{
  # Hyprland Wayland session. Runs alongside qtile (X11) — SDDM lists both,
  # so qtile stays available as a fallback while migrating.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # let existing X11 apps run under Hyprland
    withUWSM = true;        # launch via uwsm for a proper systemd/D-Bus session
  };

  # Universal Wayland Session Manager — greetd launches the Hyprland uwsm
  # session (see programs/greetd.nix).
  programs.uwsm.enable = true;

  # socat: clamshell-watch.sh reads Hyprland's event socket (socket2) to
  # reconcile the laptop panel on dock/reload without polling.
  environment.systemPackages = [ pkgs.socat ];
}
