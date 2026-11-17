# CachyOS (niri + Noctalia) work PC. Shared Linux config lives in linux.nix.
{ config, lib, pkgs, user, ... }:

let
  link = name: config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/config/${name}";
in
{
  imports = [ ../linux.nix ../which-key.nix ];

  programs.zsh.shellAliases.hms =
    "home-manager switch --flake ~/dotfiles#cachyos --impure";

  # Nix zsh does not read Arch's /etc/zsh/zprofile, so session env (PATH,
  # XDG_DATA_DIRS) must come from home-manager. CachyOS drivers cover the GPU.
  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = false;

  xdg.configFile."niri".source = link "niri";
  xdg.configFile."noctalia".source = link "noctalia";

  services.safeeyes.enable = true;

  # Warmer screen from sunset to sunrise (a user unit on graphical-session).
  # Oslo, from the system timezone. Noctalia's own night light stays off so
  # the two do not fight over the gamma.
  services.wlsunset = {
    enable = true;
    latitude = 59.9;
    longitude = 10.75;
    temperature = { day = 6500; night = 4000; };
  };

  # Keyboard-first audio, Bluetooth and network tools on Mod+Shift+A/B/N
  # (config/niri/cfg/keybinds.kdl).
  home.packages = with pkgs; [ wiremix bluetui networkmanager_dmenu fuzzel ];
  xdg.configFile."fuzzel".source = link "fuzzel";
  xdg.configFile."networkmanager-dmenu".source = link "networkmanager-dmenu";

  # keyd, Alacritty, Docker and Tailscale come from pacman (no nix keyd, no
  # nix Alacritty, no nixGL); see scripts/setup-cachyos.sh.
  home.activation.setupCachyos = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/sbin:/sbin:/usr/bin:/bin:$PATH
    ${../../scripts/setup-cachyos.sh} \
      ${user} \
      ${../../home/keyd/default.conf} \
      ${../../home/greetd} \
      ${../../config/niri/cfg} \
      ${../../config/wallpapers}
  '';
}
