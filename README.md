# Dotfiles

One Nix flake with home-manager for three hosts. Notes for agents are in
`CLAUDE.md`. Terms are in `GLOSSARY.md`. Decisions are in `docs/adr/`.

| Output | Machine | Module |
|---|---|---|
| `#pop` | Pop!_OS laptop (COSMIC, NVIDIA) | `nix/hosts/pop.nix` |
| `#cachyos` | CachyOS work PC (niri + Noctalia) | `nix/hosts/cachyos.nix` |
| `#darwin` | Intel MacBook (nixpkgs 26.05) | `nix/hosts/darwin.nix` |

## Layout

| Folder | Destination |
|---|---|
| `config/` | `~/.config` |
| `home/` | `~` |
| `system/` | `/etc` and `/usr/share`, with sudo, by a setup script |
| `nix/` | the modules |
| `scripts/` | the scripts that activation runs |
| `tests/` | the tests |

## Install

```bash
git clone <repo> ~/dotfiles && ~/dotfiles/bootstrap.sh
```

The script finds the host, installs nix and does the first switch. The first
switch takes 10–20 minutes. Old files stay as `*.backup`.

## Use

| Command | Function |
|---|---|
| `hms` | Apply the config. Use a real terminal, because setup scripts can ask for sudo. |
| `nix flake update` then `hms` | Update all inputs. Commit `flake.lock`. |
| `nr <pkg>` | Run a program from nixpkgs. |
| `ns <pkg>...` | Open a shell with programs from nixpkgs. |
| `theme`, `theme set <name>` | Show or change the theme. `theme help` shows all commands. |

Flakes read only tracked files. Do `git add` on a new file before `hms`.

`nr` and `ns` do not isolate a program. To try a program that changes the
host, use a Lima VM. The VM has its own disk and Docker. It can read `~`, but
it cannot write to it.

```bash
limactl start --name=try template:docker
limactl shell try
limactl delete -f try
```

## Packages

- CLI tools come from nix (ADR 0001).
- GPU apps and root services come from pacman or apt (ADR 0001).
- On cachyos, desktop apps come from Flatpak (ADR 0002). The list is in
  `nix/hosts/cachyos.nix`.
- Neovim plugins come from lazy.nvim. LSPs come from Mason. Nix does not pin
  them.

## Setup scripts

A setup script does work that nix cannot do on a non-NixOS host. Each script
is in `scripts/`. It does nothing when nothing changed.

| Script | Host | Function |
|---|---|---|
| `setup-zsh.sh` | Linux | Sets the nix zsh as the login shell. |
| `setup-firefox.sh` | Linux | Installs the Firefox policy: extensions, no telemetry. |
| `setup-cachyos.sh` | cachyos | Installs pacman packages, services, wallpapers and the tuigreet login screen. |
| `setup-flatpak.sh` | cachyos | Installs the Flatpak apps. |
| `setup-keyd.sh` | pop | Installs keyd and its systemd unit. |
| `setup-docker.sh`, `setup-tailscale.sh` | pop | Install Docker and Tailscale from apt. |
| `setup-alacritty.sh` | pop | Installs an Alacritty desktop entry. |

To remove a Flatpak app, remove it from the list. Then run
`flatpak uninstall --user <id>`.

## Themes

Each theme is a folder in `config/themes/`. It has one variant for dark mode
and one for light mode. The desktop sets the mode. The programs read the
active variant through `~/.local/state/theme/current`. Thus, a change does not
need `hms`.

To add a theme, add its folder, its Noctalia palette link and its nvim plugin.
Then run `tests/theme.sh`.

## CachyOS desktop

The pacman package `cachyos-niri-noctalia` supplies the desktop.
`config/niri/` and `config/noctalia/` are links to the repo, so changes apply
immediately. Put your niri settings in `config/niri/cfg/*.kdl`.

| Keys | Action |
|---|---|
| Mod+/ | Show a menu of all niri actions and their keys. |
| Mod+Escape | Lock the screen. |
| Print, Ctrl+Print, Alt+Print | Take a screenshot of an area, the screen or a window. |
| Mod+Shift+C | Open the recording menu. Press the record keys again to stop. |
| Mod+Shift+A, B, N, O | Open audio, Bluetooth, network or audio output. |

User services: Safe Eyes, wlsunset, ssh-agent and a finger-rehab reminder
every 4 hours.

## Tests

Run the tests by hand. `tests/cachyos.sh` tests the committed `HEAD` in a
container, so commit first.
