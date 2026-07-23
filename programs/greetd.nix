{ config, pkgs, ... }:

let
  # tuigreet force-bolds the Username:/Password: labels (src/ui/mod.rs
  # prompt_value adds Modifier::BOLD). On the Linux console bold both thickens
  # the stroke and shifts the hue brighter, so a bold label never matches the
  # non-bold text no matter which color we pick — it breaks the uniform
  # Matrix-green look. Patch that one modifier out so every element renders the
  # same. (Modifier stays imported — it's still used for the REVERSED buttons.)
  tuigreet = pkgs.tuigreet.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/ui/mod.rs \
        --replace 'theme.of(&[Themed::Prompt]).add_modifier(Modifier::BOLD)' 'theme.of(&[Themed::Prompt])'
    '';
  });
in

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
        # Minimal centered prompt: --width narrows the container from the
        # default 80 cols, no --time keeps the top clean. tuigreet has no flag
        # to hide the bottom action bar (F1/F2 hints), so we paint it
        # black-on-black to make it vanish on the TTY's black background —
        # 'action' is the hint text, 'button' the F-key labels. With the bold
        # patch above, a single flat 'green' (deep palette-2 green, not the
        # yellowish 'lightgreen') renders uniformly across the title, labels,
        # input and border for a consistent Matrix look.
        command = "${tuigreet}/bin/tuigreet --width 30 --remember --asterisks --theme 'text=green;time=green;container=black;border=green;title=green;greet=green;prompt=green;input=green;action=black;button=black' --cmd 'uwsm start -e -D Hyprland hyprland.desktop'";
        user = "greeter";
      };
    };
  };
}
