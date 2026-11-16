# CLI tools come from nix; GPU apps and root services come from the host's OS

Nix provides the CLI tools and all config files, the same on every host. Each host gets GPU apps (such as Alacritty) and root services (such as keyd, Docker and Tailscale) from its own OS packages, set in that host's module. On a non-NixOS host, a nix-built GPU app cannot find the NVIDIA driver without nixGL. nixGL reads the driver version when `hms` runs, so on a rolling distro such as CachyOS each driver update breaks the app until the next `hms`. A nix-built service has no systemd unit, so it needs a generated one.

## Considered Options

- **The same nix mechanism on every host** (nixGL Alacritty and nix keyd with a generated unit on both Linux hosts). Rejected: CachyOS already ships Alacritty as a dependency of its niri package, so the result is two copies, and nixGL breaks the terminal after each driver update.
- **Distro branches inside the shared module.** Rejected: host modules keep each host's exceptions in one place.

## Consequences

- The Pop!_OS host keeps its older setup (nixGL Alacritty, nix keyd with a generated unit) because it works and Pop!_OS updates the driver rarely. This is a known exception to the rule, not a pattern to copy.
- To add a tool, ask: is it a CLI tool (shared, nix) or a GPU app or root service (host module, OS package)?
- GUI apps without GPU use, such as safeeyes, can still come from nix.
