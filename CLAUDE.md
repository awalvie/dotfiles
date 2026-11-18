# Dotfiles — Nix Flake + Home Manager

One flake, three hosts: `#pop` (Pop!_OS laptop), `#cachyos` (this CachyOS
work PC, niri + Noctalia) and `#darwin` (Intel Mac). Host modules are in
`nix/hosts/`; `pop` and `cachyos` import `nix/linux.nix`, which imports
`nix/common.nix`; `darwin` imports `common.nix` directly.

`README.md` is the manual: bootstrap, what each module and setup script does,
the theme system, the CachyOS desktop. Read the section for the area you are
changing before you change it.

## Rules

- **Layout by destination** (ADR 0003): `config/` → `~/.config`, `home/` →
  `~`, `system/` → outside the home folder, installed with sudo by a setup
  script. A file lives where its main copy lands. Tests go in `tests/`;
  `scripts/` holds only what activation runs.
- **Out-of-store links** go through `link` and the `dotfiles` module
  argument (set once in `common.nix`); never hardcode `~/dotfiles`.
- **Packages** (ADR 0001, 0002): CLI tools from nix; GPU apps and root
  services from the host OS (pacman on cachyos, apt on pop); desktop apps on
  cachyos from Flatpak, listed in `nix/hosts/cachyos.nix`.
- **Setup scripts** (`scripts/setup-*.sh`, see GLOSSARY.md): idempotent, sudo
  only when something changed, runnable standalone. Wire each to its own
  `home.activation.setup<Program>` block.
- **New files** must be `git add`ed before `hms` sees them (flakes read
  tracked files only).
- **Applying**: `hms` (per-host alias, `--impure` because the flake reads
  `$USER`). Anything with sudo fails from Claude Code's `!` prefix; ask the
  user to run `hms` in a real terminal.
- **Checking a refactor**: compare
  `nix eval --impure --raw .#homeConfigurations.<host>.activationPackage.drvPath`
  before and after; identical paths mean an identical build. Run the tests
  in `tests/` that touch what changed (`tests/cachyos.sh` is a slow container
  test of `HEAD`, so commit first).

## Known gotchas

- **The first switch on a new host** is slow (10–20 min) because nix downloads
  everything into `/nix/store`. Subsequent runs are seconds. Use
  `bootstrap.sh` for it: it installs nix and enables
  flakes itself. The HM `nix.*` module can't manage `nix.conf` because it
  shells out to `nix` during activation, which needs the very feature the file
  enables; `~/.config/nix/nix.conf` is a plain symlink once HM has run.
- **Mason on NixOS** (if you ever migrate) — Mason's prebuilt binaries aren't
  patchelf'd for NixOS's dynamic linker and will fail. Not an issue on PopOS
  but worth knowing.
- **Activation scripts have a stripped PATH**. The Setup scripts are
  invoked with `export PATH=/usr/bin:/bin:$PATH` prepended to find `sudo`,
  `systemctl`, `update-desktop-database`, etc. The docker, tailscale and
  cachyos blocks also prepend `/usr/sbin:/sbin` (for `usermod`, `groupadd`).
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

## File map

```
flake.nix                       # inputs + entry points (#pop, #cachyos, #darwin)
bootstrap.sh                    # fresh host: nix install + first switch
nix/common.nix                  # OS-agnostic config (packages, zsh, git, links); sets `dotfiles`
nix/linux.nix                   # imports common + what both Linux hosts share
nix/which-key.nix               # cachyos: wlr-which-key menu of niri actions on Mod+/
nix/hosts/pop.nix               # Pop!_OS: nixGL, keyd, docker, tailscale, alacritty entry
nix/hosts/cachyos.nix           # CachyOS: niri/Noctalia links, genericLinux, services, flatpak apps
nix/hosts/darwin.nix            # Mac: plain alacritty
config/                         # → ~/.config (niri, noctalia, nvim, themes, ...)
home/                           # → ~ (.tmux.conf, .ssh/config, bin/)
home/bin/                       # scripts on PATH (theme, audio-output, niri-move-column, ...)
system/                         # → outside ~, with sudo (keyd, greetd, firefox, wallpapers)
scripts/setup-*.sh              # setup scripts, one per program or host
scripts/hms-state.sh            # the `hms` prompt marker (record/check)
scripts/niri-which-key.py       # builds the which-key menu from the niri binds
tests/                          # cachyos (container), hms-state, niri-which-key, theme
docs/adr/                       # decisions; GLOSSARY.md for terms
```

## Agent skills

### Issue tracker

Local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
