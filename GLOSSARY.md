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
