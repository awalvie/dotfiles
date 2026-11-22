# Dotfiles

One Nix flake with home-manager. It sets up three hosts:

| Output | System | Host module | Machine |
|---|---|---|---|
| `#pop` | `x86_64-linux` | `nix/hosts/pop.nix` | Pop!_OS laptop (COSMIC, NVIDIA) |
| `#cachyos` | `x86_64-linux` | `nix/hosts/cachyos.nix` | CachyOS work PC (niri + Noctalia) |
| `#darwin` | `x86_64-darwin` | `nix/hosts/darwin.nix` | Intel MacBook |

nixpkgs dropped `x86_64-darwin` after 26.05, so the Mac needs a 26.05
nixpkgs input. Notes for agents are in `CLAUDE.md`.

## Layout

Each file lives where its main copy lands (ADR 0003).

| Folder | Lands in |
|---|---|
| `config/` | `~/.config` |
| `home/` | `~` (`~/bin`, `~/.tmux.conf`, `~/.ssh/config`) |
| `system/` | outside `~` (`/etc`, `/usr/share`), installed with sudo by a setup script |
| `nix/` | the flake's modules; `nix/hosts/` has one module per host |
| `scripts/` | what activation runs: setup scripts, `hms-state.sh`, `niri-which-key.py` |
| `tests/` | tests, run by hand |

## Bootstrap a new host

```bash
git clone <repo> ~/dotfiles && ~/dotfiles/bootstrap.sh   # or: bootstrap.sh cachyos
```

`bootstrap.sh` does these steps:

1. It picks the host: macOS → `darwin`, `pacman` → `cachyos`, `apt-get` → `pop`.
2. It installs nix if nix is missing.
3. It enables flakes in `~/.config/nix/nix.conf` if that file is missing.
4. It runs the first switch with `-b backup`. Replaced files stay as `*.backup`.

You can run it again safely. The first switch takes 10–20 minutes.

## Apply changes

Run `hms`. Each host has its own alias:

```bash
hms   # home-manager switch --flake ~/dotfiles#<host> --impure
```

Before zsh is set up, use the full form:

```bash
nix run home-manager/master -- switch --flake ~/dotfiles#<host> --impure
```

- `--impure` is necessary because the flake reads `$USER`. On `pop`, nixGL also
  reads the NVIDIA driver version.
- `flake.nix` allows only the unfree `nvidia*` packages that nixGL needs.
- Flakes see only tracked files. `git add` a new file before you run `hms`.
- The laptop's output was `default` and is now `pop`. Its old `hms` alias
  fails until you switch once with the full form and `#pop`.

## Update

```bash
nix flake update             # update all inputs
nix flake update nixpkgs     # update only nixpkgs
hms                          # apply
git add flake.lock           # commit the lock so the other hosts match
```

## Setup scripts

A setup script does work that nix cannot do on a non-NixOS host, for example
it writes to `/etc`. Each script is in `scripts/`, has its own
`home.activation.setup<Program>` block, and runs on its own too. A script does
nothing when nothing changed. It asks for sudo only when it must change
something.

| Script | Hosts | Sudo | What it does |
|---|---|---|---|
| `setup-zsh.sh` | Linux | yes | Sets the nix zsh as the login shell (see below). |
| `setup-firefox.sh` | Linux | yes | Installs `system/firefox/policies.json` (see below). |
| `setup-keyd.sh` | pop | yes | Installs the keyd config and a systemd unit (see below). |
| `setup-alacritty.sh` | pop | no | Installs an Alacritty desktop entry with store paths (see below). |
| `setup-docker.sh` | pop | yes | Installs Docker from Docker's apt repo (see below). |
| `setup-tailscale.sh` | pop | yes | Installs Tailscale from its apt repo (see below). |
| `setup-cachyos.sh` | cachyos | yes | Installs packages, services and the login screen (see below). |
| `setup-flatpak.sh` | cachyos | no | Installs the Flatpak apps (see below). |

### Firefox policy

`setup-firefox.sh` installs the policy to `/etc/firefox/policies`. The policy:

- installs the extensions in every profile,
- turns off telemetry, studies, Pocket, sponsored tiles, password saving and
  first-run pages,
- turns on web apps (`browser.taskbarTabs.enabled`), for example Teams with
  "Add tab to taskbar".

Extension settings are not in the policy. uBlock, Vimium C and Containers sync
them through a Firefox account.

### CachyOS setup

`setup-cachyos.sh` does these steps:

1. It installs with pacman: keyd, Alacritty, Docker, Tailscale, Flatpak,
   OpenSSH, greetd-tuigreet, wf-recorder and slurp.
2. It installs the keyd config and enables the services, sshd included.
3. It lets SSH (TCP 22) in from the LAN `192.168.0.0/20` in ufw.
4. It adds you to the docker group and sets you as the Tailscale operator.
5. It installs the wallpapers to `/usr/share/backgrounds/dotfiles`.
6. It sets up the login screen: greetd runs tuigreet, a text greeter that
   remembers the last user and session and starts `niri-session`
   (`system/greetd/config.toml` → `/etc/greetd/config.toml`). It also removes
   what the old ReGreet login screen left.

The switch from SDDM happens at the next boot. To go back, open a text console
(Ctrl+Alt+F3), run `sudo systemctl disable greetd && sudo systemctl enable
sddm`, then reboot.

`setup-flatpak.sh` runs after it. It installs the apps listed in
`nix/hosts/cachyos.nix` from Flathub, per user (ADR 0002). It waits until
Flatpak is installed. To remove an app, delete it from the list, then run
`flatpak uninstall --user <id>`.

## What nix manages

### Packages

- **All hosts** (`nix/common.nix`): neovim, tmux, lazygit, btop, yazi, ripgrep,
  go, rustup, nodejs, python3, uv, delta, fzf, bat, direnv, stylua, yt-dlp,
  ffmpeg, the Iosevka Term nerd font and more. `make fmt` uses stylua.
- **Linux** (`nix/linux.nix`): wl-clipboard, fontconfig, xdg-utils, lima.
- **pop**: alacrittyGL, keyd, safeeyes. **darwin**: alacritty.

yazi opens with `y` and changes the folder on quit. It uses the Rosé Pine Moon
or Dawn flavour, from the terminal background.

### Shell

zsh is set up in `nix/common.nix`: history, aliases, vi-mode keys, the pure
prompt, zoxide (`z`, `zi`), `AUTO_CD` and `AUTO_PUSHD`, a highlighted
completion menu, autosuggestions and syntax highlighting.

- `o` opens a file, and the clipboard alias copies. They use `open` and
  `pbcopy` on darwin, `xdg-open` and `wl-copy` on Linux.
- `tsp` and `tsw` (Linux) switch Tailscale to the account nicknamed `personal`
  or `work`. Without the nickname they print the setup steps.
- `hms` is set per host, in the host module.

### Try a program

`nr <pkg> [args]` runs a program from nixpkgs. `ns <pkg>...` opens a shell
with the programs, and the prompt shows them. These do not isolate the
program.

To try a tool that changes the host, use a Lima VM (Linux hosts). The VM has
its own disk and Docker, and sees `~` read-only. Start it with
`limactl start --name=try template:docker`, then `limactl shell try`.
`limactl delete -f try` removes it.

### The `hms` marker

The prompt shows a gold `hms` when the repo differs from what you last
applied. The `recordHmsState` activation runs `scripts/hms-state.sh record`. It
stores HEAD and a checksum of uncommitted changes in
`~/.local/state/dotfiles/applied`. A prompt hook runs `hms-state.sh check`.
`tests/hms-state.sh` tests it.

### Git

- delta shows diffs. Its layout is in `programs.delta.options`.
- A global gitignore (`~/.config/git/ignore`) hides `.envrc`, `.venv` and
  `.direnv` in every repo.
- Pushes to `https://github.com/` go over SSH with the `~/.ssh/github` key.
  Clones and fetches stay on HTTPS. To set up a new host, run
  `ssh-keygen -t ed25519 -f ~/.ssh/github`, then `gh auth login -p ssh`. gh
  uploads the key.

### Python venvs

direnv has a `layout_uv` function. It keeps each venv in `~/venvs/<name>`, out
of the repo, and activates it when you `cd` in. Put `layout uv [name]
[python]` in a project's `.envrc`, then run `direnv allow`. One `.envrc` at a
monorepo root covers all subfolders.

### Linked config

| Link | Source | Notes |
|---|---|---|
| `~/.config/nvim` | `config/nvim/` | Out-of-store: edits apply without `hms`. |
| `~/.config/alacritty` | `config/alacritty/` | macOS reads this path too. |
| `~/.config/lazygit` | `config/lazygit/` | |
| `~/.config/btop/btop.conf` | `config/btop/btop.conf` | A local copy, made only when missing. btop rewrites the file. |
| `~/.config/nix/nix.conf` | `config/nix/nix.conf` | A plain link. The HM `nix.*` module cannot set flakes, because it needs flakes to run. |
| `~/.tmux.conf` | `home/.tmux.conf` | Copies with `pbcopy` or `wl-copy`. |
| `~/.ssh/config` | `home/.ssh/config` | Host aliases. The keys stay on each host. |
| `~/bin` | `home/bin/` | `theme`, `screen-record`, `audio-output` and more. |

The `setupCodeDirs` activation makes `~/code/{origin,lamp,work}`.

### tmux sessions

tmux-resurrect saves sessions to `~/.tmux/resurrect/`, and tmux-continuum
saves them every 15 minutes. Sessions come back when tmux starts. The plugins
come from nixpkgs (`~/.tmux-plugins.conf`).

### Themes

A **theme** is a colour family. A **variant** is one palette of it, for dark
or light. The **mode** is dark or light (GLOSSARY.md).

Themes: Rosé Pine (Moon/Dawn, the default), Gruvbox, Catppuccin
(Mocha/Latte), Tokyo Night (Night/Day), Everforest, Kanagawa (Wave/Lotus),
Solarized, Flexoki and Twilight (dark only).

- `config/themes/<theme>/<variant>/` has one file per program:
  `alacritty.toml`, `tmux.conf`, `nvim`, `btop.theme`, `sofka.toml`,
  `delta.gitconfig`, `niri.kdl` and a `mode` marker.
- `config/themes/<theme>/theme` names the `dark=` and `light=` variants and
  the `noctalia=` palette. `noctalia.json` is that palette; it is linked from
  `config/noctalia/palettes/`.
- `~/.local/state/theme/current` links to the active variant. Each program
  reads its file through that link, so a switch needs no `hms`.
- fzf, bat, delta and lazygit use the terminal's ANSI colours. They follow the
  theme with no files.

The `theme` command (`home/bin/theme`, `theme help`):

| Command | What it does |
|---|---|
| `theme` | Shows the current theme and mode. |
| `theme list` | Lists the themes. |
| `theme set <name>` | Switches theme and Noctalia's palette. |
| `theme toggle` | Flips the desktop's mode. |
| `theme apply dark\|light` | Moves the link and reloads Alacritty, tmux, nvim, btop and Claude Code. |
| `theme init` | Makes the link if it is missing (activation runs this). |

The mode follows the desktop. On `cachyos`, Noctalia's `theme_mode_changed`
hook calls `theme` (`config/noctalia/theme-hook.toml`). On `pop`, the
`theme-watch` user service follows COSMIC.

To add a theme, add its folder, its palette link in
`config/noctalia/palettes/` and its nvim plugin in
`config/nvim/lua/plugins/themes.lua`. Then run `tests/theme.sh`.

### Login shell (Linux)

`setup-zsh.sh` adds the nix zsh to `/etc/shells` and makes it your login
shell. It uses `~/.nix-profile/bin/zsh`, not a store path, so it stays valid
after updates. The change applies at the next login. macOS is not set up: its
own zsh reads the generated `~/.zshrc`.

### pop only

- **keyd**: nix installs keyd. `setup-keyd.sh` writes
  `/etc/keyd/default.conf` and a systemd unit for the nix binary, because the
  nixpkgs package has no unit.
- **Alacritty entry**: nixpkgs' `Alacritty.desktop` uses bare names that
  COSMIC cannot find. `setup-alacritty.sh` writes a copy with store paths to
  `~/.local/share/applications`.
- **nixGL**: nix-built GUI apps cannot find the host's NVIDIA driver. Without
  nixGL, Alacritty fails with `NotSupported("provided display handle is not
  supported")`. `pop.nix` wraps Alacritty as `alacrittyGL`, which runs through
  `nixGLDefault`. Wrap any other nix GPU app on `pop` the same way (ADR 0001
  says GPU apps come from the host OS). Only the `pop` config gets the `nixgl`
  input.
- **Docker** and **Tailscale** come from their apt repos, because root daemons
  from nix are hard on non-NixOS. Log out and in again for the docker group.
  Log in to Tailscale once with `tailscale up`. On macOS, install Docker
  Desktop and the Tailscale app by hand.

## CachyOS desktop (niri + Noctalia)

The pacman package `cachyos-niri-noctalia` (1.4.0-1) gives the desktop.
`nix/hosts/cachyos.nix` sets up the rest.

- `config/niri/` and `config/noctalia/` started as copies of the package's
  `/etc/skel/.config/`. They are out-of-store links, so edits apply at once.
  Put your binds, input and display settings in `config/niri/cfg/*.kdl`.
- Noctalia's settings window writes to `~/.local/state/noctalia/settings.toml`.
  That file is not in the repo, and it overrides the repo's files.

### Changes from the package

- `cfg/display.kdl` matches screens by make and model: the Dell in portrait
  left of the Samsung. The Samsung's two inputs report the same name, so it is
  matched by port (DP-3 on, HDMI-A-1 off).
- `cfg/input.kdl`: key repeat after 150 ms, 40 per second.
- Animations are off in niri and Noctalia.
- `config/noctalia/bar.toml`: a bare floating bar that hides itself.

### Keys

| Keys | Action |
|---|---|
| Mod+/ | A menu of niri actions with their keys (`nix/which-key.nix`). |
| Mod+Escape | Lock the screen. |
| Print / Ctrl+Print / Alt+Print | Screenshot: area / screen / window. |
| Mod+Shift+C | Recording menu: area or screen, with or without audio. |
| Shift+Print / Ctrl+Shift+Print | Record an area / the screen. Press again to stop. |
| Mod+Shift+A | `wiremix`, the audio mixer. |
| Mod+Shift+B | `bluetui`, Bluetooth. |
| Mod+Shift+N | `networkmanager_dmenu` in fuzzel, networks. |
| Mod+Shift+O | `audio-output`: pick the output; playing streams move to it. |

- `scripts/niri-which-key.py` builds the Mod+/ menu from
  `cfg/keybinds.kdl` at `hms` time. A new bind shows after `hms`.
- `home/bin/screen-record` saves to `~/Videos/recording-<date>.mp4`.
- `wiremix` and `bluetui` open floating (`cfg/rules.kdl`).

### Wallpapers

Public-domain paintings are in `system/wallpapers/{dark,light}/{wide,tall}/`.
They are cropped for the Samsung (3440x1440) and the Dell (1440x2560).
`config/noctalia/wallpaper.toml` changes them every 30 minutes and follows the
mode. The Dell uses the `tall` folders. To add a painting, put the file in the
correct folder and run `hms`. The lock screen shows the current painting.

### Services

- **Safe Eyes** reminds you to take breaks.
- **wlsunset** makes the screen warmer (4000 K) from sunset to sunrise, for
  Oslo. Noctalia's night light stays off, so the two do not fight. Check it
  with `journalctl --user -u wlsunset`.
- **finger-rehab** sends a notification every 4 hours of the session.
- **ssh-agent** runs as a user unit, because niri starts none.

### Why `targets.genericLinux`

The nix zsh does not read Arch's `/etc/zsh/zprofile`, so nothing reads
`/etc/profile.d`. `targets.genericLinux` puts `~/.nix-profile/bin` on `PATH`
and `~/.nix-profile/share` in `XDG_DATA_DIRS`. Then apps that niri starts find
nix tools and desktop entries. Its GPU part is off: CachyOS gives the drivers.

niri's wiki asks for an NVIDIA profile that limits VRAM use. CachyOS
`nvidia-utils` already has it.

### Checks after install

`tests/cachyos.sh` cannot test these. Check them by hand:

- `systemctl is-active keyd docker tailscaled`
- Log out and in again for the docker group, then run `tailscale up`.
- greetd logs you in to niri.
- The Noctalia bar and launcher work.
- `systemctl --user status safeeyes`

## Tests

| Test | What it tests |
|---|---|
| `tests/cachyos.sh` | Runs the bootstrap twice in an unprivileged `cachyos/cachyos` container (4 CPUs, 6 GB). It tests the committed `HEAD`, so commit first. It cannot test services or the desktop. |
| `tests/theme.sh` | The `theme` command and every theme's files. |
| `tests/hms-state.sh` | The `hms` marker. |
| `tests/niri-which-key.sh` | The Mod+/ menu builder. |

## What nix does not manage

- **Neovim plugins**: lazy.nvim manages them. `lazy-lock.json` is not in git,
  so plugins follow upstream.
- **Neovim LSPs and formatters**: Mason installs them when nvim starts (see
  `config/nvim/lua/plugins/mason.lua`). The flake does not pin them.
- **gpg**: zsh exports `GPG_TTY`, but gnupg is not installed.

## Moving to NixOS

Not done. `nix/common.nix`, `nix/linux.nix` and the host module would become a
home-manager module in a NixOS `configuration.nix`. `services.keyd.enable`
would replace `setup-keyd.sh`, and `xdg.desktopEntries` could replace
`setup-alacritty.sh`.

## To do

- Replace `setup-alacritty.sh` with `xdg.desktopEntries`.
- Install Neovim LSPs and formatters with nix instead of Mason.
- Add `gpg` to `home.packages` when you need it.
- Lint the shell scripts with `shellcheck` and `shfmt`.
