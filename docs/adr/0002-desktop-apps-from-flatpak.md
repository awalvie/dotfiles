# Desktop apps come from Flatpak; the host's package manager keeps only the base system

Refines ADR 0001 on CachyOS. Desktop apps (calibre and the like) are installed per user from Flathub, listed in `home/flatpak/apps` and installed by `scripts/setup-flatpak.sh` on each `hms`. pacman keeps only the base system: the desktop, drivers, root services (keyd, Docker, Tailscale, greetd) and `flatpak` itself. A desktop app from pacman pulls its whole library stack into the host (calibre: 84 packages, about 650 MB of Python and Qt), and those libraries stay mixed with the system's.

## Considered Options

- **pacman, as ADR 0001 says for GPU apps.** Rejected for desktop apps: every app adds its dependencies to the host, and removing it leaves the question of what else uses them.
- **nix.** Rejected: GPU apps need nixGL on a non-NixOS host, which breaks after each NVIDIA driver update on a rolling distro (ADR 0001).
- **Distrobox.** Rejected: a whole second distro to keep updated, for apps that Flathub already ships.

## Consequences

- Flatpak installs the GL extension matching the host's NVIDIA driver by itself, so GPU apps work without nixGL.
- Apps update with `flatpak update`, not with the system.
- Removing a line from `home/flatpak/apps` does not uninstall the app; run `flatpak uninstall --user <id>`.
- Pop!_OS keeps its existing setup; the same script can be wired there when an app is wanted on both.
- Terminal apps for the desktop (wiremix, bluetui) stay in nix: they use no GPU.
