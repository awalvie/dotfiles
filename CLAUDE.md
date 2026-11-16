# Dotfiles — Nix Flake + Home Manager

Cross-platform dotfiles, declaratively managed via a Nix flake and
home-manager. Hosts: a Pop!_OS laptop (COSMIC, NVIDIA), a CachyOS work PC
(niri + Noctalia; minimal so far: shared config plus its alias), and an Intel
MacBook (`x86_64-darwin`). One home-manager output per host:

- `#pop`     → `x86_64-linux` (`nix/hosts/pop.nix`)
- `#cachyos` → `x86_64-linux` (`nix/hosts/cachyos.nix`)
- `#darwin`  → `x86_64-darwin` (`nix/darwin.nix`)

`pop` and `cachyos` import `nix/linux.nix` (shared Linux config), which imports
`nix/common.nix` (the OS-agnostic bulk); `darwin` imports `common.nix` directly. Note: nixpkgs is
deprecating `x86_64-darwin` after the 26.05 release, so Intel-mac support has a
long-term clock on it.

## Quick context

- **Repo layout**: `config/` and `home/` hold raw config files. home-manager
  just symlinks the existing files into `~/.config/`, `~/`, etc. (The pre-nix
  `unix/` and `darwin/` layouts have been removed — both OSes are now driven by
  the flake. The old darwin zsh/git were superseded by the flake, its ssh
  config moved to `config/ssh/config`, and its k9s config was dropped as
  unused.)
- **Nix lives in**: `flake.nix` (root) + `nix/{common,linux,pop,cachyos,darwin}.nix`.
  `common.nix` holds everything shared; `linux.nix` holds what both Linux hosts
  share (clipboard tools, fontconfig, xdg-utils, `xclip` alias, zsh setup
  activation); each host module (`pop`/`cachyos`/`darwin`) adds its
  own packages, activations, and `hms` alias.
- **Per-program glue**: `scripts/setup-*.sh` — one script per program for
  setup nix can't do declaratively on a non-NixOS host. Each is wired to its
  own `home.activation.setup<Program>` block in `nix/hosts/pop.nix` (all current
  ones are Pop!_OS-only, except `setup-zsh.sh`, wired in `nix/linux.nix`), runs standalone too, and is idempotent (only acts when
  something changed). Currently:
  - `setup-keyd.sh` — sudo; installs keyd config + a generated systemd unit
    into `/etc`.
  - `setup-alacritty.sh` — no sudo; installs a desktop entry into
    `~/.local/share/applications` with absolute nix-store paths.
  - `setup-zsh.sh` — sudo; sets the nix zsh as the login shell.
  - `setup-docker.sh` — sudo; installs Docker Engine from Docker's official
    apt repo, enables the daemon, adds the user to the docker group.

## Bootstrap (fresh host)

```bash
git clone <repo> ~/dotfiles && ~/dotfiles/bootstrap.sh   # works from any shell, incl. fish
~/dotfiles/bootstrap.sh cachyos                          # an argument overrides detection
~/dotfiles/bootstrap.sh --detect                         # just print the detected host
```

`bootstrap.sh` (repo root, bash) detects the host (macOS -> `darwin`, `pacman` ->
`cachyos`, `apt-get` -> `pop`), installs nix with the upstream multi-user
installer if missing, writes `~/.config/nix/nix.conf` (flakes on) only if it
does not exist, then runs `nix run home-manager/master -- switch -b backup
--flake <repo>#<host> --impure`. Existing files the switch replaces (e.g. the
CachyOS skel `~/.config/alacritty`) are kept as `*.backup`. Re-running it is
safe: it skips the nix install and the `nix.conf` step. It ends by printing the
remaining manual steps.

### Container test

`scripts/test-cachyos.sh` runs the bootstrap in a plain unprivileged
`cachyos/cachyos` container (never `--privileged`, never systemd as init) with
`cachyos-niri-noctalia` installed, so the real skel files are present. It
archives the committed `HEAD` (commit first), runs the bootstrap twice as a
sudo-capable user, and asserts: the switch succeeds, replaced skel files have
`.backup` copies, and the second run skips the nix install and `nix.conf`.
Containers are capped at `--cpus=4 --memory=6g`. The base image (packages +
user) is cached as `dotfiles-test-cachyos-base` (`--rebuild` redoes it) and
`/nix` lives in the named volume `dotfiles-test-nix`, so source builds happen
once. A warm volume skips the nix installer, so only a cold run (`--fresh`
deletes the volume) exercises it. The container is always removed on exit. Add new asserts
with `check "description" cmd...` near the end of the script.

It does NOT cover: systemd services (the installer cannot start `nix-daemon`
there, so the test starts it by hand; enabling/starting keyd, docker, tailscale
etc. are manual checks), SDDM, and the real niri/noctalia desktop.

## How to apply changes

```bash
# from anywhere — `hms` is a per-host alias:
hms                # pop     -> home-manager switch --flake ~/dotfiles#pop     --impure
                   # cachyos -> home-manager switch --flake ~/dotfiles#cachyos --impure
                   # darwin -> home-manager switch --flake ~/dotfiles#darwin  --impure

# or the full form, e.g. from a fresh shell before zshrc is in place:
nix run home-manager/master -- switch --flake ~/dotfiles#pop     --impure  # pop
nix run home-manager/master -- switch --flake ~/dotfiles#cachyos --impure  # cachyos
nix run home-manager/master -- switch --flake ~/dotfiles#darwin  --impure  # darwin
```

The laptop's output was renamed `default` → `pop`, so its old `hms` alias
points at a missing output until it switches once with the full form above
(`#pop`); after that `hms` works again.

The `--impure` is required on both OSes because the flake reads `$USER` via
`builtins.getEnv` (and on Linux, because nixGL's NVIDIA wrapper detects the
host driver version at eval time). The unfree NVIDIA driver pulled in by nixGL
is allowed via a scoped `config.allowUnfreePredicate` in `flake.nix` (matches
only `nvidia*`), so no blanket `NIXPKGS_ALLOW_UNFREE` env var is needed.

Anything added to the repo must be `git add`ed (not necessarily committed)
before `hms` will see it — flakes only operate on tracked files.

## What nix manages

- Cross-platform CLI packages in `common.nix`'s `home.packages` (neovim, tmux,
  lazygit, ripgrep, go, rustup, nodejs, python3, uv, delta, fzf, bat, direnv,
  stylua, yt-dlp, ffmpeg, iosevka-term nerd font, etc.). `stylua` is the lua formatter the
  repo's `Makefile fmt` target calls — now nix-managed rather than via Mason.
  OS-specific packages are added in the per-OS modules: `alacrittyGL`, `keyd`,
  `safeeyes` in `pop.nix`; `wl-clipboard`, `xclip`, `fontconfig`, `xdg-utils`
  in `linux.nix` (both Linux hosts); plain
  `alacritty` in `darwin.nix`.
- zsh config (in `common.nix`): history, aliases, vi-mode bindings, pure prompt
  (via `pkgs.pure-prompt`), zoxide (`programs.zoxide`, the `z`/`zi` jump
  commands — replaced the older `zsh-z`), navigation setopts (AUTO_CD,
  AUTO_PUSHD), completion zstyles (highlighted menu, case-insensitive matching,
  ls-colors), autosuggestion, syntax highlighting. The clipboard command and
  `o` alias are OS-conditional
  (`pbcopy`/`open` on darwin, `wl-copy`/`xdg-open` on linux); the `hms` alias
  is defined per host in `pop.nix`/`cachyos.nix`/`darwin.nix` (different `--flake` target).
- Theme: Rosé Pine (main) is set in three places only: Alacritty (inline
  colours), Neovim (`rose-pine/neovim` in `config/nvim/lua/plugins/rose-pine.lua`,
  with MiniTabline and BlinkCmp highlight tweaks) and sofka
  (`skin.name = "rose-pine"`). Everything else follows the terminal palette.
- git config (delta integration, settings.user.{name,email}). delta's layout
  (line numbers, file labels, hunk headers, blame, merge conflicts) is inline in
  `programs.delta.options`.
- Terminal-palette colours: fzf (no colour options), bat (`ansi` theme), delta
  (terminal colour names, `syntax-theme = ansi`), lazygit's delta pager and tmux
  (colour names) all use the terminal's ANSI colours, so a terminal theme change
  reaches them with no edits. No hex colours live in their config.
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
    Colours are the official Rosé Pine (main) palette, inline in `alacritty.toml`.
  - `~/.config/lazygit` ← `config/lazygit/`
  - `~/.config/nix/nix.conf` ← `config/nix/nix.conf` (enables flakes + the new
    nix CLI; a flat symlink on purpose, not the HM `nix.*` module — see the
    gotcha below)
  - `~/.tmux.conf` ← `home/.tmux.conf` (clipboard `copy-command` is split via
    `if-shell uname` — `pbcopy` on darwin, `wl-copy` on linux)
  - `~/.ssh/config` ← `config/ssh/config` (host aliases; the referenced
    `IdentityFile`s are per-machine, not in the repo)
  - `~/bin` ← `home/bin/` (hublink script)
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
  `NotSupported("provided display handle is not supported")`. `pop.nix`
  wraps `pkgs.alacritty` via `symlinkJoin` + `makeWrapper` into `alacrittyGL`,
  whose `bin/alacritty` runs through `nixGLDefault` while keeping the original
  `/share` (so the launcher entry inherits the GL-correct binary). The activation
  block passes `alacrittyGL` (not `pkgs.alacritty`) to `setup-alacritty.sh`.
  Any future nix-installed GUI/GL app on linux needs the same `nixGL` wrap.
  macOS (`darwin.nix`) uses plain `pkgs.alacritty` — no wrap needed. The
  `nixgl` input is only passed to the `pop` config's `extraSpecialArgs`, so the
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
- docker (linux-only), indirectly: `setup-docker.sh` installs Docker Engine
  from Docker's official apt repo (CLI + daemon + compose plugin), enables the
  systemd unit, and adds the user to the `docker` group. NOT nix-managed — a
  nix-store dockerd is painful on non-NixOS, and apt is what Docker supports on
  Ubuntu/PopOS. Sudo prompt + apt work only fire on first run; idempotent
  after. Group membership needs a re-login to take effect. (macOS uses Docker
  Desktop, installed separately.)
- tailscale (linux-only), indirectly: `setup-tailscale.sh` installs Tailscale
  from its official apt repo, enables `tailscaled`, and sets the user as the
  operator (CLI without sudo; per-profile, so re-run `hms` after adding a
  profile). NOT nix-managed — root daemon on non-NixOS, same
  reason as docker. Login is manual, once: `tailscale up`. (macOS uses the
  Tailscale app, installed separately.)

### CachyOS desktop (niri + Noctalia)

`nix/hosts/cachyos.nix` only. The desktop itself comes from the pacman package
`cachyos-niri-noctalia` (version 1.4.0-1 when these files were copied).
- `config/niri/` and `config/noctalia/` are copies of that package's
  `/etc/skel/.config/{niri,noctalia}`. `~/.config/niri` and
  `~/.config/noctalia` are out-of-store symlinks
  (`mkOutOfStoreSymlink`) to `~/dotfiles/config/...`, so edits reload at once
  without `hms`. Put your own keybinds, input and display settings in
  `config/niri/cfg/*.kdl`. Noctalia's GUI writes its settings to
  `~/.local/state/noctalia/settings.toml`; that state is not managed.
- `targets.genericLinux.enable = true` (GPU part off: CachyOS ships the
  drivers). Why: the nix zsh does not read Arch's `/etc/zsh/zprofile`, so
  nothing sources `/etc/profile.d`. Home-manager's session vars then put
  `~/.nix-profile/bin` on `PATH` and `~/.nix-profile/share` in
  `XDG_DATA_DIRS` (also via `environment.d`), so apps started by niri and the
  launcher find nix tools and desktop entries.
- `services.safeeyes.enable = true`: a user unit wanted by
  `graphical-session.target` (Pop!_OS keeps the plain package in `pop.nix`).
- NVIDIA VRAM: niri's wiki asks for a driver profile limiting VRAM use.
  CachyOS `nvidia-utils` already ships it
  (`/etc/nvidia/nvidia-application-profiles-rc.d/limit-vram-usage`), so
  nothing to do.
- Post-install checks (not in the container test): log in to niri from SDDM;
  the Noctalia bar appears; the launcher lists nix apps; `systemctl --user
  status safeeyes` is running.

## What nix does NOT manage (and why)

- **Neovim plugins** — `lazy.nvim` manages those. `lazy-lock.json` is
  deliberately gitignored (NOT pinned) — plugins float to upstream HEAD by
  choice.
- **Neovim LSPs/formatters** — Mason auto-installs them at nvim startup. See
  `config/nvim/lua/plugins/mason.lua` for the `ensure_installed` list. This is
  a known soft spot — Mason binaries aren't pinned by the flake.
- **gpg** — referenced in zshrc (`GPG_TTY` is exported) but not in
  `home.packages` yet. Add when actually used. (`xdg-utils` is now declared on
  linux.)

## Known gotchas

- **First `hms` on a new machine** is slow (10–20 min) because nix downloads
  everything into `/nix/store`. Subsequent runs are seconds. Use the
  `bootstrap.sh` script (above) for the first run: it installs nix and enables
  flakes itself. The HM `nix.*` module can't manage `nix.conf` because it
  shells out to `nix` during activation, which needs the very feature the file
  enables; `~/.config/nix/nix.conf` is a plain symlink once HM has run.
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

Not done, but the structure ports cleanly: `nix/common.nix` (+ `nix/linux.nix` and
the relevant host module) becomes a home-manager module imported from a NixOS
`configuration.nix`. The
`setup-keyd.sh` script and the keyd activation block both go away in favor
of `services.keyd.enable = true;` (the alacritty entry can stay as a
home-manager `xdg.desktopEntries` block). Worth doing when the manual sudo
prompts
start feeling like friction.

## Follow-up TODOs

- **Replace `setup-alacritty.sh` with `xdg.desktopEntries`**. Now that
  alacritty is a wrapped derivation, home-manager's native `xdg.desktopEntries`
  could generate the launcher entry declaratively and drop the script + its
  brittle `sed` rewrite.
- **Pin Neovim LSPs/formatters via nix** instead of Mason (the known soft
  spot) — would also fix the eventual NixOS-Mason patchelf problem.
- **Move `gpg` into `home.packages`** if you start using it
  (`GPG_TTY` is exported but gnupg isn't installed).
- **Shell-script linting** — add `shellcheck`/`shfmt` (+ Makefile targets) for
  `scripts/*.sh` and `home/bin/*`; nothing lints them today.

## File map

```
bootstrap.sh                    # fresh-host bootstrap: nix install + first switch
scripts/test-cachyos.sh         # container test of the bootstrap on CachyOS
flake.nix                       # flake inputs + entry points (#pop, #cachyos, #darwin)
nix/common.nix                  # OS-agnostic config (packages, programs, symlinks)
nix/linux.nix                   # imports common + bits shared by both Linux hosts
nix/hosts/pop.nix               # Pop!_OS host: nixGL, keyd, setup scripts, hms alias
nix/hosts/cachyos.nix           # CachyOS host: shared Linux config + niri/Noctalia links, genericLinux, safeeyes, hms alias
nix/darwin.nix                  # imports common + macOS bits (plain alacritty)
scripts/setup-keyd.sh           # sudo: keyd /etc config + systemd unit (hm activation, linux)
scripts/setup-alacritty.sh      # no sudo: alacritty desktop entry (hm activation, linux)
scripts/setup-zsh.sh            # sudo: set nix zsh as login shell (hm activation, linux)
scripts/setup-docker.sh         # sudo: install docker engine via apt (hm activation, linux)
scripts/setup-tailscale.sh      # sudo: install tailscale via apt (hm activation, linux)
config/                         # configs symlinked into ~/.config/
home/                           # configs symlinked into ~/
home/bin/                       # custom shell scripts (hublink)
```

## Agent skills

### Issue tracker

Local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
