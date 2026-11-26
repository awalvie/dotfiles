#!/usr/bin/env python3
"""Build a wlr-which-key menu from niri's key binds.

Usage: niri-which-key.py <keybinds.kdl>  (prints the config as JSON, which
wlr-which-key reads as YAML)

Each `Key { action; }` bind becomes a menu entry that runs the action and
whose label shows the bind, so the menu doubles as a cheat sheet and always
matches the config. Entries are grouped by what the action does.
"""
import json
import re
import sys

BIND = re.compile(r"^\s*(?P<key>[A-Za-z0-9_+]+)\s+(?P<props>[^{]*)\{\s*(?P<action>[^;]+);\s*\}")
TITLE = re.compile(r'hotkey-overlay-title="([^"]*)"')

# (menu key, title, test on the niri action name), first match wins.
GROUPS = [
    ("f", "Focus (move around)", lambda a: a.startswith("focus-") and "workspace" not in a and "monitor" not in a),
    ("v", "Move (carry the window)", lambda a: a.startswith("move-") and "workspace" not in a and "monitor" not in a),
    ("d", "Workspaces", lambda a: "workspace" in a),
    ("m", "Monitors", lambda a: "monitor" in a),
    ("s", "Screenshots", lambda a: a.startswith("screenshot")),
    ("w", "Window and column", lambda a: any(w in a for w in ("window", "column", "width", "height", "consume", "expel"))),
    ("a", "Apps and panels", lambda a: a.startswith("spawn")),
    ("o", "Other", lambda a: True),
]

# Entries that are not niri binds.
EXTRAS = {
    "o": [
        ("Toggle dark/light theme", "theme toggle"),
        ("Suspend", "systemctl suspend"),
        ("Reboot", "systemctl reboot"),
        ("Power off", "systemctl poweroff"),
    ],
}

# Colours here are a fallback: home/bin/which-key swaps in the current
# theme's colours each time the menu opens.
STYLE = {
    "font": "IosevkaTerm Nerd Font 13",
    "background": "#232136",
    "color": "#e0def4",
    "border": "#c4a7e7",
    "separator": "  ",
    "border_width": 2,
    "corner_r": 12,
    "padding": 16,
    "anchor": "center",
}


# Friendlier names for keys in the labels.
KEY_NAMES = {
    "CTRL": "Ctrl", "ALT": "Alt", "ESCAPE": "Esc", "TAB": "Tab", "Return": "Enter",
    "BracketLeft": "[", "BracketRight": "]", "Comma": ",", "Period": ".",
    "Minus": "-", "Equal": "=",
}


def pretty(bind):
    return "+".join(KEY_NAMES.get(part, part) for part in bind.split("+"))


def label(action, title):
    if title:
        return title.split(":")[0]
    return action.split()[0].replace("-", " ").capitalize() + "".join(
        " " + arg.strip('"') for arg in action.split()[1:]
    )


def command(action):
    name, _, args = action.partition(" ")
    if name == "spawn":
        return " ".join(re.findall(r'"([^"]*)"', args))
    if name == "spawn-sh":
        return re.findall(r'"([^"]*)"', args)[0]
    return f"niri msg action {action}"


def own_key(bind):
    """The bind's own letter or digit, e.g. `h` for Mod+Ctrl+H."""
    last = bind.split("+")[-1] if bind else ""
    return last.lower() if len(last) == 1 else None


def assign_keys(binds):
    """Give each entry its bind's own key where free, then the first free one."""
    keys, used = [None] * len(binds), set()
    for i, bind in enumerate(binds):
        k = own_key(bind)
        if k and k not in used:
            keys[i] = k
            used.add(k)
    free = (k for k in "abcdefghijklmnopqrstuvwxyz0123456789" if k not in used)
    return [k or next(free) for k in keys]


def main(path):
    groups = {key: [] for key, _, _ in GROUPS}
    for line in open(path):
        m = BIND.match(line)
        if not m or "Wheel" in m["key"] or m["key"].startswith("XF86"):
            continue
        action = m["action"].strip()
        if "which-key" in action:
            continue
        title = TITLE.search(m["props"])
        # Group by the main action: `focus-column-or-monitor-left` is a focus
        # move that only crosses monitors at the edge, and the column-move
        # script is a column move.
        if "niri-move-column" in action:
            name = "move-column-to-monitor" if "--monitor" in action else "move-column"
        else:
            name = action.split()[0].split("-or-")[0]
        key = next(k for k, _, test in GROUPS if test(name))
        groups[key].append((label(action, title and title[1]), pretty(m["key"]), command(action)))

    menu = []
    for key, title, _ in GROUPS:
        entries = groups[key] + [(d, "", c) for d, c in EXTRAS.get(key, [])]
        if not entries:
            continue
        width = max(len(d) for d, _, _ in entries)
        keys = assign_keys([bind for _, bind, _ in entries])
        sub = [
            {"key": k, "desc": f"{desc:<{width}}  {bind}".rstrip(), "cmd": cmd}
            for k, (desc, bind, cmd) in zip(keys, entries)
        ]
        menu.append({"key": key, "desc": title, "submenu": sub})

    # wlr-which-key closes only on Esc; a no-op entry makes q close it too
    menu.append({"key": "q", "desc": "Close", "cmd": "true"})
    print(json.dumps(STYLE | {"menu": menu}, indent=2))


if __name__ == "__main__":
    main(sys.argv[1])
