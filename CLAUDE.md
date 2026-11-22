# Dotfiles — Nix Flake + Home Manager

One flake, three hosts: `#pop` (Pop!_OS laptop), `#cachyos` (this CachyOS
work PC, niri + Noctalia) and `#darwin` (Intel Mac). Host modules are in
`nix/hosts/`. `pop` and `cachyos` import `nix/linux.nix`, which imports
`nix/common.nix`. `darwin` imports `common.nix` directly.

`README.md` is the manual. Read the section for an area before you change it.

## Rules

- **Layout by destination** (ADR 0003): `config/` → `~/.config`, `home/` →
  `~`, `system/` → outside `~`, installed with sudo by a setup script. A file
  lives where its main copy lands. Tests go in `tests/`. `scripts/` holds only
  what activation runs.
- **Out-of-store links** use `link` and the `dotfiles` module argument (set in
  `common.nix`). Do not write `~/dotfiles` in a path.
- **Packages** (ADR 0001, 0002): CLI tools come from nix. GPU apps and root
  services come from the host OS (pacman on cachyos, apt on pop). Desktop apps
  on cachyos come from Flatpak, listed in `nix/hosts/cachyos.nix`.
- **Setup scripts** (`scripts/setup-*.sh`, GLOSSARY.md): they do nothing when
  nothing changed, use sudo only when they must change something, and run on
  their own. Give each one its own `home.activation.setup<Program>` block.
- **New files**: `git add` them before `hms`. Flakes read only tracked files.
- **Apply** with `hms`, the per-host alias (`--impure`, because the flake
  reads `$USER`). Sudo fails from Claude Code's `!` prefix, so ask the user to
  run `hms` in a real terminal.
- **Check a refactor**: compare
  `nix eval --impure --raw .#homeConfigurations.<host>.activationPackage.drvPath`
  before and after. The same path means the same build. Run the tests in
  `tests/` for what changed. `tests/cachyos.sh` is a slow container test of
  `HEAD`, so commit first.
- **Docs** use Simple Technical English and Orwell's rules: short words, short
  sentences, active voice, no word that does no work.
- **ADRs** in `docs/adr/` are records. Do not edit an accepted ADR; write a new
  one that supersedes it.

## Known gotchas

- **The first switch** on a new host takes 10–20 minutes, because nix fills
  `/nix/store`. Use `bootstrap.sh`: it installs nix and enables flakes. The HM
  `nix.*` module cannot write `nix.conf`, because it runs `nix` during
  activation and so needs flakes already. `~/.config/nix/nix.conf` is a plain
  link.
- **Activation scripts have a short PATH.** Each setup script call starts with
  `export PATH=/usr/bin:/bin:$PATH` to find `sudo`, `systemctl` and the rest.
  The docker, tailscale and cachyos blocks also add `/usr/sbin:/sbin` (for
  `usermod`, `groupadd`).
- **home-manager changes fast.** We track `home-manager/master`. If you see
  `option 'X' has been renamed to 'Y'`, follow the rename. Done so far:
  - `programs.git.userName` → `programs.git.settings.user.name`
  - `programs.git.userEmail` → `programs.git.settings.user.email`
  - `programs.git.extraConfig` → `programs.git.settings`
  - `programs.git.delta.*` → `programs.delta.*`
- **nixpkgs `keyd` has no systemd unit.** It expects NixOS's
  `services.keyd.enable`, so `setup-keyd.sh` writes the unit.
- **Mason on NixOS** (if we move): Mason's binaries do not run on NixOS's
  dynamic linker. This does not affect the current hosts.

## File map

```
flake.nix                       # inputs + outputs (#pop, #cachyos, #darwin)
bootstrap.sh                    # new host: install nix + first switch
nix/common.nix                  # all hosts: packages, zsh, git, links; sets `dotfiles`
nix/linux.nix                   # both Linux hosts; imports common.nix
nix/which-key.nix               # cachyos: the Mod+/ menu of niri actions
nix/hosts/pop.nix               # Pop!_OS: nixGL, keyd, docker, tailscale, alacritty entry
nix/hosts/cachyos.nix           # CachyOS: niri/Noctalia links, services, flatpak apps
nix/hosts/darwin.nix            # Mac: plain alacritty
config/                         # → ~/.config (niri, noctalia, nvim, themes, ...)
home/                           # → ~ (.tmux.conf, .ssh/config, bin/)
home/bin/                       # scripts on PATH (theme, screen-record, audio-output, ...)
system/                         # → outside ~, with sudo (keyd, greetd, firefox, wallpapers)
scripts/setup-*.sh              # setup scripts, one per program or host
scripts/hms-state.sh            # the `hms` prompt marker (record/check)
scripts/niri-which-key.py       # builds the which-key menu from the niri binds
tests/                          # cachyos (container), hms-state, niri-which-key, theme
docs/adr/                       # decisions; GLOSSARY.md for terms
```

## Agent skills

- **Issue tracker**: Markdown files in `.scratch/<feature>/`. See
  `docs/agents/issue-tracker.md`.
- **Triage labels**: the five defaults (`needs-triage`, `needs-info`,
  `ready-for-agent`, `ready-for-human`, `wontfix`). See
  `docs/agents/triage-labels.md`.
- **Domain docs**: one context, `GLOSSARY.md` and `docs/adr/` at the root. See
  `docs/agents/domain.md`.
