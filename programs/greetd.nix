{ config, pkgs, ... }:

{
  # greetd + tuigreet: minimal Wayland-native login on the TTY. Replaces SDDM
  # (which rendered its greeter on X11). tuigreet is a console program, so there
  # is no graphics stack to fail — worst case is a text prompt, never a blank
  # graphical screen. Launches the Hyprland uwsm session (see programs/hyprland.nix
  # withUWSM); the command mirrors the generated hyprland-uwsm.desktop Exec so
  # Hyprland runs inside a proper systemd/D-Bus user session.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd 'uwsm start -e -D Hyprland hyprland.desktop'";
        user = "greeter";
      };
    };
  };
}
