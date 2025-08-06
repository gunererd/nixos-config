# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook
from libqtile.log_utils import logger

mod = "mod4"
terminal = guess_terminal()

# Floating window stacking system
floating_stacks = {}  # Dict to store stacked floating windows
stackable_windows = set()  # Windows marked as stackable

# Draggable windows tracking
draggable_windows = set()  # Set to store window IDs that can be dragged/resized

@lazy.function
def bring_or_spawn_terminal(qtile):
    """Bring existing terminal to current group or spawn new one"""
    terminal_name = terminal.capitalize()  # Convert "alacritty" to "Alacritty"
    
    for group in qtile.groups:
        for window in group.windows:
            if window.window.get_wm_class() and terminal_name in window.window.get_wm_class():
                # Move window to current group and focus it
                window.togroup(qtile.current_group.name)
                qtile.current_group.focus(window)
                # Center the window
                window.cmd_set_position_floating(100, 100)
                return
    # No terminal found, spawn new one
    qtile.spawn(terminal)

@lazy.function
def resize_window_larger(qtile):
    """Increase window size (floating only)"""
    window = qtile.current_window
    if window.floating:
        # Increase floating window size by 100px in each dimension, centered
        width, height = window.width, window.height
        x, y = window.x, window.y
        new_width = width + 100
        new_height = height + 100
        # Move window to keep it centered
        new_x = x - 50
        new_y = y - 50
        window.cmd_set_size_floating(new_width, new_height)
        window.cmd_set_position_floating(new_x, new_y)

@lazy.function 
def resize_window_smaller(qtile):
    """Decrease window size (floating only)"""
    window = qtile.current_window
    if window.floating:
        # Decrease floating window size by 100px in each dimension, centered
        width, height = window.width, window.height
        x, y = window.x, window.y
        new_width = max(200, width - 100)  # Minimum 200px width
        new_height = max(150, height - 100)  # Minimum 150px height
        # Move window to keep it centered
        width_diff = width - new_width
        height_diff = height - new_height
        new_x = x + width_diff // 2
        new_y = y + height_diff // 2
        window.cmd_set_size_floating(new_width, new_height)
        window.cmd_set_position_floating(new_x, new_y)

class DragFloatingWindow:
    """Custom drag class that only works on draggable windows"""
    def __init__(self):
        self.drag_handler = lazy.window.set_position_floating()
        # Copy necessary attributes from the original handler
        self.selectors = self.drag_handler.selectors
        self.name = self.drag_handler.name
        self.args = self.drag_handler.args
        self.kwargs = self.drag_handler.kwargs
    
    def check(self, qtile):
        window = qtile.current_window
        with open("/tmp/qtile_debug.log", "a") as f:
            f.write(f"Drag check: window {window.wid if window else None}, in set: {window.wid in draggable_windows if window else False}, set: {draggable_windows}\n")
        return window and window.wid in draggable_windows
    
    def __call__(self, qtile, *args, **kwargs):
        window = qtile.current_window
        if window and window.wid in draggable_windows:
            with open("/tmp/qtile_debug.log", "a") as f:
                f.write(f"Allowing drag for window {window.wid}\n")
            return self.drag_handler(qtile, *args, **kwargs)
        with open("/tmp/qtile_debug.log", "a") as f:
            f.write(f"Blocking drag for window {window.wid if window else None}\n")

class ResizeFloatingWindow:
    """Custom resize class that only works on draggable windows"""
    def __init__(self):
        self.resize_handler = lazy.window.set_size_floating()
        # Copy necessary attributes from the original handler
        self.selectors = self.resize_handler.selectors
        self.name = self.resize_handler.name
        self.args = self.resize_handler.args
        self.kwargs = self.resize_handler.kwargs
    
    def check(self, qtile):
        window = qtile.current_window
        with open("/tmp/qtile_debug.log", "a") as f:
            f.write(f"Resize check: window {window.wid if window else None}, in set: {window.wid in draggable_windows if window else False}, set: {draggable_windows}\n")
        return window and window.wid in draggable_windows
    
    def __call__(self, qtile, *args, **kwargs):
        window = qtile.current_window
        if window and window.wid in draggable_windows:
            with open("/tmp/qtile_debug.log", "a") as f:
                f.write(f"Allowing resize for window {window.wid}\n")
            return self.resize_handler(qtile, *args, **kwargs)
        with open("/tmp/qtile_debug.log", "a") as f:
            f.write(f"Blocking resize for window {window.wid if window else None}\n")

@lazy.function
def toggle_floating_centered(qtile):
    """Toggle floating and center/resize window if going to floating"""
    window = qtile.current_window
    was_floating = window.floating
    window.cmd_toggle_floating()
    
    # Update draggable windows set
    if window.floating:
        draggable_windows.add(window.wid)
        with open("/tmp/qtile_debug.log", "a") as f:
            f.write(f"Toggle: Added window {window.wid} to draggable set: {draggable_windows}\n")
    else:
        draggable_windows.discard(window.wid)
        with open("/tmp/qtile_debug.log", "a") as f:
            f.write(f"Toggle: Removed window {window.wid} from draggable set: {draggable_windows}\n")
    
    # If window just became floating, center and resize it
    if not was_floating and window.floating:
        # Get screen dimensions
        screen = qtile.current_screen
        screen_width = screen.width
        screen_height = screen.height
        
        # Default floating window size (80% of screen)
        default_width = int(screen_width * 0.8)
        default_height = int(screen_height * 0.8)
        
        # Center position
        center_x = (screen_width - default_width) // 2
        center_y = (screen_height - default_height) // 2
        
        window.cmd_set_size_floating(default_width, default_height)
        window.cmd_set_position_floating(center_x, center_y)

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    # Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", bring_or_spawn_terminal, desc="Bring or spawn terminal"),

    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "v", toggle_floating_centered, desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Key([mod], "space", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "space", lazy.spawn("rofi -show drun"), desc="Spawn a command using a prompt widget"),
    Key([mod], "a", lazy.spawn("rofi -show window"), desc="Show window switcher"),
    Key([mod], "s", lazy.spawn("rofi -modi \"clipboard:greenclip print\" -show clipboard"), desc="Show clipboard history"),
    Key([mod], "d", lazy.spawn("dolphin"), desc="Spawn a filemanager"),
    Key([mod], "x", lazy.spawn("i3lock-fancy -g"), desc="Lock screen with live desktop blur"),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +5%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%-")),

    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),

    # Window resizing
    Key([mod], "equal", resize_window_larger, desc="Increase window size"),
    Key([mod], "minus", resize_window_smaller, desc="Decrease window size"),
    Key([mod, "shift"], "s", lazy.spawn("sh -c 'maim -s ~/Pictures/$(date +%Y%m%d-%H%M%S).png'"), desc="Screenshot to file"),

]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=0),
    layout.Max(),
    layout.Stack(num_stacks=2, border_width=0),
    layout.Matrix(border_width=0),
    layout.Zoomy(border_width=0),
]


widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", DragFloatingWindow(), start=lazy.window.get_position()),
    Drag([mod], "Button3", ResizeFloatingWindow(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_width=0,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="Alacritty"),
        Match(title="dolphin"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

floating_classes = ["Alacritty", "dolphin"]

@hook.subscribe.client_new
def set_floating_by_default(window):
    # Float all windows by default
    window.toggle_floating()
    window.bring_to_front()  # Keep floating windows on top
    
    # Add to draggable windows set since it's now floating
    draggable_windows.add(window.wid)
    with open("/tmp/qtile_debug.log", "a") as f:
        f.write(f"New window {window.wid} added to draggable set: {draggable_windows}\n")
    
    # Get screen dimensions and set sensible default size
    screen = qtile.current_screen
    screen_width = screen.width
    screen_height = screen.height
    
    # Default size: 16:10 aspect ratio, 80% of screen width
    default_width = int(screen_width * 0.8)
    default_height = int(default_width / 1.6)  # 16:10 aspect ratio
    
    # Center the window
    center_x = (screen_width - default_width) // 2
    center_y = (screen_height - default_height) // 2
    
    with open("/tmp/qtile_debug.log", "a") as f:
        f.write(f"Setting window {window.wid} size to {default_width}x{default_height} (screen: {screen_width}x{screen_height})\n")
    
    window.cmd_set_size_floating(default_width, default_height)
    window.cmd_set_position_floating(center_x, center_y)

@hook.subscribe.client_focus
def maintain_float_on_top(window):
    # Ensure floating windows stay on top when focused
    if window.floating:
        window.bring_to_front()
    else:
        # If tiled window is focused, bring all floating windows to front
        for win in window.group.windows:
            if win.floating:
                win.bring_to_front()

@hook.subscribe.client_killed
def cleanup_draggable_windows(window):
    # Remove window from draggable set when it's closed
    draggable_windows.discard(window.wid)
    logger.info(f"Window {window.wid} killed, removed from draggable set: {draggable_windows}")

