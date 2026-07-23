# qtile (X11) → Hyprland + Noctalia migration

Target: **stinkpad first**, incremental, with qtile kept as a fallback SDDM
session throughout. Not doing a 1:1 port of the custom floating-window qtile
workflow — Noctalia (Quickshell shell) replaces most standalone modules.

## Steps

- [x] 1. Read `CLAUDE.md` and follow repo conventions before writing modules.
- [x] 2. `programs/hyprland.nix` — enable Hyprland; imported in stinkpad
      configuration.nix alongside qtile (fallback stays available). Starter
      `dotfiles/stinkpad/hypr/hyprland.lua` added (Lua config, testable session:
      terminal/close/exit/workspaces, xkb + XCURSOR carried over from X11).
      Validated with `nixos-rebuild dry-build` (Hyprland 0.55.4, lua-5.5.0).
- [x] 3. Noctalia wiring — `programs/noctalia.nix`: `pkgs.noctalia-shell` (4.7.7,
      ships a `noctalia-shell` binary), `services.upower` +
      `services.power-profiles-daemon` on. Autostart added to hyprland.lua via
      `hl.on("hyprland.start", ...)`. Used nixpkgs package (no flake/Cachix
      needed). Validated with `nixos-rebuild dry-build`.
- [x] 4. `hyprland.lua` — full keybind port from qtile config.py into the `hl`
      API (focus/move/resize vim keys, workspaces 1-9, floating/fullscreen,
      mouse drag/resize). Launcher/window-switcher/clipboard/lock/volume/
      brightness routed through Noctalia IPC (`noctalia-shell ipc call ...`).
      Parse-checked with lua loadfile.
- [x] 5. Wayland utilities — grim + slurp added to screenshot.nix, cliphist to
      clipman.nix (X11 tools kept for qtile fallback until step 7). `NIXOS_OZONE_WL=1`
      set via `hl.env` in hyprland.lua. Clipboard watcher (`wl-paste --watch
      cliphist store`) autostarted alongside Noctalia.
- [ ] 6. Rebuild & test — log into Hyprland session; qtile remains if it breaks.
- [~] 7. Clean up (stinkpad done) — replaced SDDM (X11 greeter) with
      `programs/greetd.nix` (greetd + tuigreet, launches Hyprland directly).
      Removed stinkpad imports: qtile, picom, rofi, dunst, betterlockscreen,
      sddm. Removed the `services.xserver` block (X server + sessionCommands)
      and the X11 Xresources from ui.nix. Shared module FILES kept because
      tiny/vm still import them (qtile/X11); delete them only after migrating
      those machines. All 3 machines dry-build clean.
      `tiny` and `vm` now migrated too (same import swap, X server block +
      X11-era scale vars removed, `hypr/hyprland.lua` added per host; vm keeps
      spice-vdagentd/qemuGuest, drops the X11 `spice-vdagent -x` service and
      sets `WLR_NO_HARDWARE_CURSORS`). All 3 dry-build clean.
      TODO: boot-test tiny/vm, then delete the now-unused shared modules
      (qtile/picom/rofi/dunst/betterlockscreen/sddm) and strip
      maim/greenclip from screenshot.nix/clipman.nix.

## Modules Noctalia replaces (delete at step 7)

| Current | Fate |
|---|---|
| rofi.nix (launcher) | Noctalia launcher |
| dunst.nix (notifications) | Noctalia notifications |
| betterlockscreen.nix / i3lock-fancy | Noctalia lock |
| picom.nix (compositor) | built into Hyprland |
| xwallpaper (in sessionCommands) | Noctalia wallpaper |
| scripts/notifications/*.sh (volume/brightness OSD) | Noctalia OSD |
| clipman / greenclip | Noctalia clipboard, or cliphist |
| maim / slop (screenshot.nix) | grim + slurp |
| qtile.nix | hyprland.nix |

## Gotchas

- Config uses NixOS modules, **no home-manager** → Noctalia configured via its
  own runtime settings GUI (persists to `~/.config`). Add home-manager later if
  declarative Noctalia config is wanted.
- Electron/Chromium apps need `NIXOS_OZONE_WL=1` or they run blurry under XWayland.
- Cursor/GTK theming (`ui.nix` XCURSOR/Xresources) needs Wayland env-var equivalents.
- HiDPI (dpi=120, XCURSOR_SIZE=48) → use Hyprland `monitor` scaling.
- Noctalia flake requires nixpkgs unstable (already on it).
- **Hyprland version: 0.55.4** from pinned nixpkgs (`b5aa0fb`). 0.55 switched to a
  **Lua** config (`~/.config/hypr/hyprland.lua`, global `hl` table). Old hyprlang
  (`hyprland.conf`) still works but is dropped in ~1-2 releases — so we write Lua.
- Noctalia's documented `exec-once`/`bind` snippets are hyprlang; translate them
  to the Lua `hl` API. Noctalia itself talks to Hyprland over IPC — format-agnostic.

## Refs

- https://docs.noctalia.dev/v4/getting-started/nixos/
- https://wiki.nixos.org/wiki/Noctalia_Shell
- https://search.nixos.org/packages?channel=unstable&show=noctalia-shell
