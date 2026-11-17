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

  # Animated wallpaper: Noctalia's mpvpaper plugin plays videos from ~/Videos.
  # On first run, assign this one to every screen (the plugin then owns the
  # choice; pick another from its panel).
  home.file."Videos/rain-cyber-balcony.gif".source = ../../config/wallpapers/rain-cyber-balcony.gif;
  home.activation.setupWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      assignments = pkgs.writeText "mpvpaper-assignments.json" (builtins.toJSON {
        assignments."*" = "${config.home.homeDirectory}/Videos/rain-cyber-balcony.gif";
        lastAssignments = { };
      });
    in
    ''
      f=${config.xdg.stateHome}/noctalia/mpvpaper/assignments.json
      [ -e "$f" ] || $DRY_RUN_CMD install -Dm644 ${assignments} "$f"
    ''
  );

  # keyd, Alacritty, Docker and Tailscale come from pacman (no nix keyd, no
  # nix Alacritty, no nixGL); see scripts/setup-cachyos.sh.
  home.activation.setupCachyos = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/sbin:/sbin:/usr/bin:/bin:$PATH
    ${../../scripts/setup-cachyos.sh} \
      ${user} \
      ${../../home/keyd/default.conf} \
      ${../../home/greetd} \
      ${../../config/niri/cfg} \
      ${../../config/wallpapers/rain-cyber-balcony.gif}
  '';
}
