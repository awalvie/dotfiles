# Dotfiles — Nix Flake + Home Manager

Cross-platform dotfiles, declaratively managed via a Nix flake and
home-manager. The primary host is Linux on COSMIC (PopOS-based, NVIDIA); an
Intel MacBook (`x86_64-darwin`) is also supported by the same flake. Two
home-manager outputs share a common module:

- `#default` → `x86_64-linux` (`nix/linux.nix`)
- `#darwin`  → `x86_64-darwin` (`nix/darwin.nix`)

Both import `nix/common.nix` (the OS-agnostic bulk). Note: nixpkgs is
deprecating `x86_64-darwin` after the 26.05 release, so Intel-mac support has a
long-term clock on it.

## Quick context

- **Repo layout**: `config/` and `home/` hold raw config files. home-manager
  just symlinks the existing files into `~/.config/`, `~/`, etc. (The pre-nix
  `unix/` and `darwin/` layouts have been removed — both OSes are now driven by
  the flake. The old darwin zsh/git were superseded by the flake, its ssh
  config moved to `config/ssh/config`, and its k9s config was dropped as
  unused.)
- **Nix lives in**: `flake.nix` (root) + `nix/{common,linux,darwin}.nix`.
  `common.nix` holds everything shared; `linux.nix`/`darwin.nix` each
  `import` it and add OS-specific packages, activations, and the `hms` alias.
- **Per-program glue**: `scripts/setup-*.sh` — one script per program for
  setup nix can't do declaratively on a non-NixOS host. Each is wired to its
  own `home.activation.setup<Program>` block in `nix/linux.nix` (all current
  ones are Linux-only), runs standalone too, and is idempotent (only acts when
  something changed). Currently:
  - `setup-keyd.sh` — sudo; installs keyd config + a generated systemd unit
    into `/etc`.
  - `setup-alacritty.sh` — no sudo; installs a desktop entry into
    `~/.local/share/applications` with absolute nix-store paths.

## How to apply changes

```bash
# from anywhere — `hms` is an OS-specific alias defined per platform:
hms                # linux  -> NIXPKGS_ALLOW_UNFREE=1 home-manager switch \
                   #             --flake ~/dotfiles#default --impure
                   # darwin ->                         home-manager switch \
                   #             --flake ~/dotfiles#darwin  --impure

# or the full form, e.g. from a fresh shell before zshrc is in place:
NIXPKGS_ALLOW_UNFREE=1 nix run home-manager/master -- \
  switch --flake ~/dotfiles#default --impure          # linux
nix run home-manager/master -- \
  switch --flake ~/dotfiles#darwin --impure           # darwin
```

The `--impure` is required on both OSes because the flake reads `$USER` via
`builtins.getEnv` (and on Linux, because nixGL's NVIDIA wrapper detects the
host driver version at eval time). `NIXPKGS_ALLOW_UNFREE=1` is Linux-only —
it's there for the unfree NVIDIA driver pulled in by nixGL (see the nixGL note
under "What nix manages"); darwin has nothing unfree.

Anything added to the repo must be `git add`ed (not necessarily committed)
before `hms` will see it — flakes only operate on tracked files.

## What nix manages

- Cross-platform CLI packages in `common.nix`'s `home.packages` (neovim, tmux,
  lazygit, ripgrep, go, rustup, nodejs, python3, uv, delta, fzf, bat, direnv,
  stylua, iosevka-term nerd font, etc.). `stylua` is the lua formatter the
  repo's `Makefile fmt` target calls — now nix-managed rather than via Mason.
  OS-specific packages are added in the per-OS modules: `alacrittyGL`, `keyd`,
  `wl-clipboard`, `xclip`, `fontconfig` in `linux.nix`; plain `alacritty` in
  `darwin.nix`.
- zsh config (in `common.nix`): history, aliases, vi-mode bindings, pure prompt
  (via `pkgs.pure-prompt`), zsh-z (via `pkgs.zsh-z`), autosuggestion, syntax
  highlighting. The clipboard command and `o` alias are OS-conditional
  (`pbcopy`/`open` on darwin, `wl-copy`/`xdg-open` on linux); the `hms` alias
  is defined per-OS in `linux.nix`/`darwin.nix` (different `--flake` target).
- git config (delta integration, includes for theme, settings.user.{name,email}).
  Also a global gitignore (`programs.git.ignores` → `~/.config/git/ignore`) for
  `.envrc`/`.venv`/`.direnv` so venv/direnv artifacts never show up in any
  repo's status — important for the monorepo.
- python venvs via direnv: `programs.direnv.stdlib` defines a `layout_uv` that
  keeps venvs centralized in `~/venvs/<name>` (out of the repo) and
  auto-activates them on cd. Drop `layout uv [name] [python]` in a project's
  `.envrc` (one at a monorepo root covers all subdirs), then `direnv allow`.
  Replaced the old hand-rolled `uvenv` shell wrapper.
- Config file symlinks via `xdg.configFile` and `home.file`:
  - `~/.config/nvim` ← `config/nvim/`
  - `~/.config/alacritty` ← `config/alacritty/` (shared; macOS alacritty reads
    `~/.config/alacritty` too)
  - `~/.config/lazygit` ← `config/lazygit/`
  - `~/.tmux.conf` ← `home/.tmux.conf` (clipboard `copy-command` is split via
    `if-shell uname` — `pbcopy` on darwin, `wl-copy` on linux)
  - `~/.ssh/config` ← `config/ssh/config` (host aliases; the referenced
    `IdentityFile`s are per-machine, not in the repo)
  - `~/.Xmodmap` ← `home/.Xmodmap` (linux-only; dead on COSMIC/Wayland, kept
    for parity)
  - `~/bin` ← `home/bin/` (battery, hublink scripts)
- keyd (linux-only), indirectly: nix installs the binary, `setup-keyd.sh` writes
  `/etc/keyd/default.conf` and a generated `/etc/systemd/system/keyd.service`
  pointing to the nix-store keyd binary, then enables+restarts the service.
  Sudo prompt only fires when config or unit file actually changed.
- alacritty desktop entry (linux-only), indirectly: `setup-alacritty.sh` rewrites nixpkgs'
  `Alacritty.desktop` (which uses bare `Exec=alacritty`/`Icon=Alacritty` that
  COSMIC can't resolve) to absolute store paths and drops it in
  `~/.local/share/applications`. No sudo.
- **nixGL** (`nixgl` flake input, linux-only): nix-built GUI apps can't find
  this NVIDIA host's GL/EGL driver (it lives in PopOS FHS paths, version-locked
  to the kernel module). Without it, alacritty dies with
  `NotSupported("provided display handle is not supported")`. `linux.nix`
  wraps `pkgs.alacritty` via `symlinkJoin` + `makeWrapper` into `alacrittyGL`,
  whose `bin/alacritty` runs through `nixGLDefault` while keeping the original
  `/share` (so the launcher entry inherits the GL-correct binary). The activation
  block passes `alacrittyGL` (not `pkgs.alacritty`) to `setup-alacritty.sh`.
  Any future nix-installed GUI/GL app on linux needs the same `nixGL` wrap.
  macOS (`darwin.nix`) uses plain `pkgs.alacritty` — no wrap needed. The
  `nixgl` input is only passed to the linux config's `extraSpecialArgs`, so the
  darwin config never evaluates it.
- login shell (linux-only), indirectly: `setup-zsh.sh` adds the nix zsh to `/etc/shells` and
  `sudo chsh`es the user to it. It targets the stable
  `~/.nix-profile/bin/zsh` symlink (passed as `config.home.profileDirectory`),
  NOT a `/nix/store` path, so it survives GC/rebuilds and doesn't re-run on
  every update. Idempotent (no-op when the shell already matches). Takes effect
  on next login. Not wired on macOS — macOS already defaults to zsh and sources
  the generated `~/.zshrc` regardless of which zsh binary is the login shell;
  add a darwin chsh path later if you want the nix zsh as the actual login bin.
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
- **gpg, yt-dlp, xdg-utils** — referenced in zshrc aliases/usage but not
  currently in `home.packages`. Add when needed. (kubectl/k8s tooling was
  dropped — no longer used.)

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

Not done, but the structure ports cleanly: `nix/common.nix` (+ the linux bits
of `nix/linux.nix`) becomes a home-manager module imported from a NixOS
`configuration.nix`. The
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
- **Move `gpg`/`yt-dlp`/`xdg-utils` into `home.packages`** — referenced in zsh
  usage but not yet declared.
- **`setup-zsh.sh` leaves stale `/etc/shells` entries** across profile-path
  changes (it only appends). Harmless, but a cleanup pass would be tidy.

## File map

```
flake.nix                       # flake inputs + entry points (#default linux, #darwin mac)
nix/common.nix                  # OS-agnostic config (packages, programs, symlinks)
nix/linux.nix                   # imports common + linux bits (nixGL, keyd, setup scripts)
nix/darwin.nix                  # imports common + macOS bits (plain alacritty)
scripts/setup-keyd.sh           # sudo: keyd /etc config + systemd unit (hm activation, linux)
scripts/setup-alacritty.sh      # no sudo: alacritty desktop entry (hm activation, linux)
scripts/setup-zsh.sh            # sudo: set nix zsh as login shell (hm activation, linux)
config/                         # configs symlinked into ~/.config/
home/                           # configs symlinked into ~/
home/bin/                       # custom shell scripts (battery, hublink)
```
