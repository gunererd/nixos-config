-- Hyprland Lua config (Hyprland 0.55+, global `hl` table).
-- STARTER config for the migration smoke test — enough to log in, open a
-- terminal, move windows, and exit. Full keybind translation from the old
-- qtile config.py, plus Noctalia autostart, lands in a later migration step.
-- Ref: https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "alacritty"
local fileManager = "nautilus"

-------------------
---- AUTOSTART ----
-------------------

-- Noctalia (Quickshell shell): bar, launcher, notifications, OSDs, lock.
hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia-shell")
    -- Clipboard history backend for Noctalia's clipboard launcher.
    hl.exec_cmd("wl-paste --watch cliphist store")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "48")
hl.env("HYPRCURSOR_SIZE", "48")
hl.env("NIXOS_OZONE_WL", "1") -- Electron/Chromium apps render natively on Wayland

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 6,
        border_size = 1,
        layout      = "dwindle",
    },
    decoration = {
        rounding = 8,
    },
    animations = {
        enabled = false,
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        -- Carried over from the X11 setup (services.xserver.xkb.options)
        kb_options   = "altwin:swap_lalt_lwin,ctrl:swapcaps",
        follow_mouse = 1,
    },
})

-- Corne has its own layout; no xkb swaps (keys in their physical positions).
hl.device({
    name       = "corne-choc-pro-keyboard",
    kb_options = "",
})

-----------------------
---- WINDOW RULES ----
-----------------------

hl.window_rule({ match = { class = "org.gnome.Nautilus" }, float = true })
hl.window_rule({ match = { class = "imv" }, float = true })

---------------------
---- KEYBINDINGS ----
---------------------

-- mod = SUPER, mirroring the old qtile config (mod4). Noctalia's IPC
-- (`noctalia-shell ipc call <target> <method>`) replaces rofi/greenclip/i3lock
-- and drives the volume/brightness OSDs.
local mainMod = "SUPER"
local ipc     = "noctalia-shell ipc call "

-- Programs
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))            -- qtile: bring/spawn terminal
hl.bind(mainMod .. " + d",      hl.dsp.exec_cmd(fileManager))         -- qtile: dolphin
hl.bind(mainMod .. " + space",  hl.dsp.exec_cmd(ipc .. "launcher toggle"))    -- qtile: rofi -show drun
hl.bind(mainMod .. " + a",      hl.dsp.exec_cmd(ipc .. "launcher windows"))   -- qtile: rofi -show window
hl.bind(mainMod .. " + s",      hl.dsp.exec_cmd(ipc .. "launcher clipboard")) -- qtile: greenclip history
hl.bind(mainMod .. " + x",      hl.dsp.exec_cmd(ipc .. "lockScreen lock"))    -- qtile: i3lock-fancy
hl.bind(mainMod .. " + Tab",    hl.dsp.exec_cmd("dictate-toggle"))            -- voice dictation (English): press to record, press to type
hl.bind(mainMod .. " + t",      hl.dsp.exec_cmd("dictate-turkish"))           -- voice dictation (Turkish via Gemini): press to record, press to type

-- Window management
hl.bind(mainMod .. " + q",             hl.dsp.window.close())                      -- qtile: kill window
hl.bind(mainMod .. " + f",             hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + v",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.layout("togglesplit"))            -- dwindle split toggle
hl.bind(mainMod .. " + CONTROL + r",   hl.dsp.exec_cmd("hyprctl reload"))         -- qtile: reload config
hl.bind(mainMod .. " + CONTROL + q",   hl.dsp.exit())                             -- qtile: shutdown WM

-- Focus (vim keys)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))

-- Move window (vim keys)
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))

-- Resize window (vim keys + equal/minus)
hl.bind(mainMod .. " + CONTROL + h", hl.dsp.window.resize({ x = -40, y = 0 }))
hl.bind(mainMod .. " + CONTROL + l", hl.dsp.window.resize({ x = 40,  y = 0 }))
hl.bind(mainMod .. " + CONTROL + k", hl.dsp.window.resize({ x = 0,   y = -40 }))
hl.bind(mainMod .. " + CONTROL + j", hl.dsp.window.resize({ x = 0,   y = 40 }))
hl.bind(mainMod .. " + equal", hl.dsp.window.resize({ x = 40,  y = 40 }))
hl.bind(mainMod .. " + minus", hl.dsp.window.resize({ x = -40, y = -40 }))

-- Screenshot: area select to ~/Pictures (qtile used maim -s; grim + slurp on Wayland)
hl.bind(mainMod .. " + SHIFT + s",
    hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | tee ~/Pictures/$(date +%Y%m%d-%H%M%S).png | wl-copy --type image/png']]))

-- Workspaces 1-9 (qtile groups "123456789")
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Move/resize with mouse (qtile: mod+Button1 drag, mod+Button3 resize)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness via Noctalia (shows OSD, controls the real device)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(ipc .. "volume increase"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(ipc .. "volume decrease"),   { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(ipc .. "volume muteOutput"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(ipc .. "brightness increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness decrease"), { locked = true, repeating = true })
