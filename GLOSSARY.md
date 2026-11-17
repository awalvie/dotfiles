# Dotfiles

One Nix flake with home-manager that sets up every machine the owner uses.

## Language

**Host**:
One machine with its own flake output and its own `hms` alias: `pop` (Pop!_OS laptop), `cachyos` (CachyOS work PC) or `darwin` (Intel Mac).
_Avoid_: machine, box, target, system

**Setup script**:
A script in `scripts/` that does work nix cannot do on a non-NixOS host, such as writing to `/etc`, for one program or for one host. Activation calls it, and it does nothing when nothing changed.
_Avoid_: install script, hook

**Bootstrap**:
The one command that takes a fresh clone of the repo to a working host, including installing nix and the first switch.
_Avoid_: install, setup, first run

**Theme**:
A colour family, such as Rosé Pine, kept as one folder in `config/themes/`. Its `theme` file names the variant for dark and for light; a theme with one entry uses it in both modes.
_Avoid_: skin, colourscheme

**Variant**:
One palette of a theme, such as Moon or Dawn: a subfolder with one file per program.
_Avoid_: flavour, scheme

**Mode**:
Dark or light, as set by the desktop. The mode picks which variant of the current theme is applied.
_Avoid_: appearance, brightness
