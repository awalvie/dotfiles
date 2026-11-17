# Pop!_OS (COSMIC, NVIDIA) laptop. Shared Linux config lives in linux.nix.
{ config, pkgs, lib, user, nixgl, ... }:

let
  # nixGL wrapper that injects the host NVIDIA driver paths at runtime.
  nixGL = nixgl.packages.${pkgs.stdenv.hostPlatform.system}.nixGLDefault;

  # alacritty, but with its `bin/alacritty` wrapped through nixGL. symlinkJoin
  # keeps the original /share (desktop entry + icon) intact, so the launcher
  # entry that setup-alacritty.sh generates points at the GL-correct binary.
  alacrittyGL = pkgs.symlinkJoin {
    name               = "alacritty-nixgl";
    paths              = [ pkgs.alacritty ];
    nativeBuildInputs  = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/alacritty
      makeWrapper ${nixGL}/bin/nixGL $out/bin/alacritty \
        --add-flags ${pkgs.alacritty}/bin/alacritty
    '';
  };
in
{
  imports = [ ../linux.nix ];

  home.packages = with pkgs; [
    alacrittyGL
    keyd
    safeeyes       # break reminder (RSI), GTK tray app
  ];

  # hms targets this host's config; --impure for $USER and the nixGL driver.
  programs.zsh.shellAliases.hms =
    "home-manager switch --flake ~/dotfiles#pop --impure";

  # Follows COSMIC's dark/light mode: the portal's colour-scheme signal drives
  # `theme apply` (see home/bin/theme-watch).
  systemd.user.services.theme-watch = {
    Unit = {
      Description = "Apply the theme variant when COSMIC changes dark/light mode";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.glib}/bin/gdbus monitor --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop | ${config.home.homeDirectory}/bin/theme-watch'";
      Environment = [ "PATH=${config.home.profileDirectory}/bin:/usr/bin:/bin" "XDG_CURRENT_DESKTOP=COSMIC" ];
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Per-program setup for things nix/home-manager can't manage declaratively on
  # a non-NixOS host. Each program gets its own script in scripts/.
  home.activation.setupKeyd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../../scripts/setup-keyd.sh} \
      ${pkgs.keyd}/bin/keyd \
      ${../../home/keyd/default.conf}
  '';

  home.activation.setupAlacritty = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../../scripts/setup-alacritty.sh} \
      ${alacrittyGL}
  '';

  # docker installed from Docker's official apt repo (not nix — the daemon
  # needs root/systemd/networking that's painful to run from /nix/store on a
  # non-NixOS host). /usr/sbin is on PATH for usermod/groupadd.
  home.activation.setupDocker = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/sbin:/sbin:/usr/bin:/bin:$PATH
    ${../../scripts/setup-docker.sh} \
      ${user}
  '';

  # Tailscale: apt repo + tailscaled + operator. Login stays manual (browser).
  home.activation.setupTailscale = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/sbin:/sbin:/usr/bin:/bin:$PATH
    ${../../scripts/setup-tailscale.sh} \
      ${user}
  '';
}
