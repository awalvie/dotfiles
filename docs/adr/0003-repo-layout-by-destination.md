# Repo files are grouped by where they end up

Each top-level folder of raw files is named after its destination: `config/` goes to `~/.config`, `home/` to `~`, and `system/` outside the home folder (`/etc`, `/usr/share`), installed with sudo by a setup script. Inside `system/` files are grouped by program (`system/keyd/`, `system/greetd/`, ...), and each setup script decides where they go. A file shared by two destinations lives where its main copy lands: the niri `display.kdl` stays in `config/niri/cfg/` and the login screen gets a copy. Lists of things to install are nix lists in the host module, not files. `scripts/` holds only what activation runs; tests live in `tests/`.

The split by destination also splits by privilege: everything in `system/` needs sudo, so it only applies when `hms` runs in a real terminal.

## Considered Options

- **One folder per program** (GNU stow style: `niri/`, `keyd/`, `ssh/`). The most common dotfiles layout, and it keeps a program's files together. Rejected: about twenty top-level folders, and the nix has to be read to learn where each lands or whether it needs sudo.
- **One folder per host** (`common/`, `linux/`, `cachyos/`), mirroring `nix/`. Rejected: a program moves folders whenever it becomes shared or stops being shared.
- **The earlier loose split.** `config/` and `home/` already existed, but `config/ssh` went to `~/.ssh`, `config/wallpapers` to `/usr/share` and `home/{keyd,greetd,firefox}` to `/etc`.

## Consequences

- One program can span folders: niri in `config/`, its login screen in `system/greetd/`.
- Moving a file keeps its nix store path when its name and content stay the same, so a pure move leaves the build identical.
