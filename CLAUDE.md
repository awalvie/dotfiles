# Dotfiles — Nix Flake + Home Manager

Linux dotfiles, declaratively managed via a Nix flake and home-manager.
Currently running on COSMIC (PopOS-based). Darwin support was intentionally
removed.

## Quick context

- **Repo layout**: `config/`, `home/`, `unix/`, `darwin/` (legacy, ignore)
  hold raw config files. Nothing in there was restructured during nix
  migration — home-manager just symlinks the existing files into `~/.config/`,
  `~/`, etc.
- **Nix lives in**: `flake.nix` (root) + `nix/home.nix` (the real config).
- **Per-program glue**: `scripts/setup-*.sh` — one script per program for
  setup nix can't do declaratively on a non-NixOS host. Each is wired to its
  own `home.activation.setup<Program>` block in `nix/home.nix`, runs standalone
  too, and is idempotent (only acts when something changed). Currently:
  - `setup-keyd.sh` — sudo; installs keyd config + a generated systemd unit
    into `/etc`.
  - `setup-alacritty.sh` — no sudo; installs a desktop entry into
    `~/.local/share/applications` with absolute nix-store paths.

## How to apply changes

```bash
# from anywhere
hms                # alias for:
                   #   NIXPKGS_ALLOW_UNFREE=1 home-manager switch \
                   #     --flake ~/dotfiles#default --impure

# or the full form, e.g. from a fresh shell before zshrc is in place:
NIXPKGS_ALLOW_UNFREE=1 nix run home-manager/master -- \
  switch --flake ~/dotfiles#default --impure
```

The `--impure` is required because the flake reads `$USER` via
`builtins.getEnv`, and because nixGL's NVIDIA wrapper detects the host driver
version at eval time. `NIXPKGS_ALLOW_UNFREE=1` is required because that NVIDIA
driver is unfree (see the nixGL note under "What nix manages").

Anything added to the repo must be `git add`ed (not necessarily committed)
before `hms` will see it — flakes only operate on tracked files.

## What nix manages

- All CLI packages declared in `home.packages` (neovim, tmux, lazygit, ripgrep,
  go, rustup, nodejs, python3, uv, alacritty, delta, fzf, bat, direnv, keyd,
  stylua, iosevka-term nerd font, etc.). `stylua` is the lua formatter the
  repo's `Makefile fmt` target calls — now nix-managed rather than via Mason.
- zsh config: history, aliases, vi-mode bindings, pure prompt (via
  `pkgs.pure-prompt`), zsh-z (via `pkgs.zsh-z`), autosuggestion, syntax
  highlighting
- git config (delta integration, includes for theme, settings.user.{name,email})
- Config file symlinks via `xdg.configFile` and `home.file`:
  - `~/.config/nvim` ← `config/nvim/`
  - `~/.config/alacritty` ← `config/alacritty/`
  - `~/.config/lazygit` ← `config/lazygit/`
  - `~/.tmux.conf` ← `home/.tmux.conf`
  - `~/.Xmodmap` ← `home/.Xmodmap` (dead on COSMIC/Wayland, kept for parity)
  - `~/bin` ← `home/bin/` (battery, hublink, uvenv scripts)
- keyd, indirectly: nix installs the binary, `setup-keyd.sh` writes
  `/etc/keyd/default.conf` and a generated `/etc/systemd/system/keyd.service`
  pointing to the nix-store keyd binary, then enables+restarts the service.
  Sudo prompt only fires when config or unit file actually changed.
- alacritty desktop entry, indirectly: `setup-alacritty.sh` rewrites nixpkgs'
  `Alacritty.desktop` (which uses bare `Exec=alacritty`/`Icon=Alacritty` that
  COSMIC can't resolve) to absolute store paths and drops it in
  `~/.local/share/applications`. No sudo.
- **nixGL** (`nixgl` flake input): nix-built GUI apps can't find this NVIDIA
  host's GL/EGL driver (it lives in PopOS FHS paths, version-locked to the
  kernel module). Without it, alacritty dies with
  `NotSupported("provided display handle is not supported")`. `home.nix`
  wraps `pkgs.alacritty` via `symlinkJoin` + `makeWrapper` into `alacrittyGL`,
  whose `bin/alacritty` runs through `nixGLDefault` while keeping the original
  `/share` (so the launcher entry inherits the GL-correct binary). The activation
  block passes `alacrittyGL` (not `pkgs.alacritty`) to `setup-alacritty.sh`.
  Any future nix-installed GUI/GL app needs the same `nixGL` wrap.
- login shell, indirectly: `setup-zsh.sh` adds the nix zsh to `/etc/shells` and
  `sudo chsh`es the user to it. It targets the stable
  `~/.nix-profile/bin/zsh` symlink (passed as `config.home.profileDirectory`),
  NOT a `/nix/store` path, so it survives GC/rebuilds and doesn't re-run on
  every update. Idempotent (no-op when the shell already matches). Takes effect
  on next login.
- `~/code/{origin,lamp,work}` workspace dirs — created by the
  `setupCodeDirs` activation block (inline `mkdir -p`, no sudo, no script —
  too trivial to warrant one).

## What nix does NOT manage (and why)

- **Neovim plugins** — `lazy.nvim` manages those, pinned via `lazy-lock.json`
- **Neovim LSPs/formatters** — Mason auto-installs them at nvim startup. See
  `config/nvim/lua/plugins/mason.lua` for the `ensure_installed` list. This is
  a known soft spot — Mason binaries aren't pinned by the flake. Migration to
  nix-managed LSPs is on the list but not done.
- **Docker** — daemon-based, install via apt/official installer
- **kubectl, helm, gpg, yt-dlp, xdg-utils** — referenced in zshrc aliases but
  not currently in `home.packages`. Add when needed.

## Known gotchas

- **First `hms` on a new machine** is slow (10–20 min) because nix downloads
  everything into `/nix/store`. Subsequent runs are seconds.
- **Mason on NixOS** (if you ever migrate) — Mason's prebuilt binaries aren't
  patchelf'd for NixOS's dynamic linker and will fail. Not an issue on PopOS
  but worth knowing.
- **Activation scripts have a stripped PATH**. The `setup-*.sh` scripts are
  invoked with `export PATH=/usr/bin:/bin:$PATH` prepended to find `sudo`,
  `systemctl`, `update-desktop-database`, etc.
- **home-manager API moves fast**. We're tracking `home-manager/master`. If
  you hit `option 'X' has been renamed to 'Y'` warnings, follow the rename.
  We already migrated:
  - `programs.git.userName` → `programs.git.settings.user.name`
  - `programs.git.userEmail` → `programs.git.settings.user.email`
  - `programs.git.extraConfig` → `programs.git.settings`
  - `programs.git.delta.*` → top-level `programs.delta.*`
- **nixpkgs `keyd` package doesn't ship a systemd unit** — we generate one
  in `setup-keyd.sh` because keyd's nixpkgs package assumes you're on NixOS
  and using `services.keyd.enable`.

## Updating

```bash
nix flake update             # bump everything in flake.lock
nix flake update nixpkgs     # bump just nixpkgs
hms                          # apply
git add flake.lock           # commit the lock so other machines match
```

## Migration to NixOS

Not done, but the structure ports cleanly: `nix/home.nix` becomes a
home-manager module imported from a NixOS `configuration.nix`. The
`setup-keyd.sh` script and the keyd activation block both go away in favor
of `services.keyd.enable = true;` (the alacritty entry can stay as a
home-manager `xdg.desktopEntries` block). Worth doing when the manual sudo
prompts
start feeling like friction.

## Follow-up TODOs

- **Narrow the unfree allowance**. `hms` currently exports a blanket
  `NIXPKGS_ALLOW_UNFREE=1` for the nixGL NVIDIA driver. Tighten to an
  `allowUnfreePredicate` that permits only the nvidia driver, so the rest of
  the config stays unfree-clean.
- **Replace `setup-alacritty.sh` with `xdg.desktopEntries`**. Now that
  alacritty is a wrapped derivation, home-manager's native `xdg.desktopEntries`
  could generate the launcher entry declaratively and drop the script.
- **Pin Neovim LSPs/formatters via nix** instead of Mason (the known soft
  spot) — would also fix the eventual NixOS-Mason patchelf problem.
- **Move `kubectl`/`helm`/`gpg`/`yt-dlp`/`xdg-utils` into `home.packages`** —
  referenced in zsh aliases but not yet declared.
- **`setup-zsh.sh` leaves stale `/etc/shells` entries** across profile-path
  changes (it only appends). Harmless, but a cleanup pass would be tidy.

## File map

```
flake.nix                       # flake inputs + entry points
nix/home.nix                    # the real config (packages, programs, symlinks)
scripts/setup-keyd.sh           # sudo: keyd /etc config + systemd unit (hm activation)
scripts/setup-alacritty.sh      # no sudo: alacritty desktop entry (hm activation)
scripts/setup-zsh.sh            # sudo: set nix zsh as login shell (hm activation)
config/                         # configs symlinked into ~/.config/
home/                           # configs symlinked into ~/
unix/, darwin/                  # legacy pre-nix layout, not actively used
home/bin/                       # custom shell scripts (battery, hublink, uvenv)
```
