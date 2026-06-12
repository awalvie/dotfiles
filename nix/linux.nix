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
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    alacrittyGL
    keyd
    wl-clipboard
    xclip
    fontconfig
  ];

  fonts.fontconfig.enable = true;

  # X11-only, dead on COSMIC/Wayland but kept for parity.
  home.file.".Xmodmap".source = ../home/.Xmodmap;

  # linux-only aliases. hms targets the linux config and needs the unfree
  # allowance for the nixGL NVIDIA driver.
  programs.zsh.shellAliases = {
    xclip = "xclip -selection clipboard";
    hms   = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake ~/dotfiles#default --impure";
  };

  # Per-program setup for things nix/home-manager can't manage declaratively on
  # a non-NixOS host. Each program gets its own script in scripts/.
  home.activation.setupKeyd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../scripts/setup-keyd.sh} \
      ${pkgs.keyd}/bin/keyd \
      ${../home/keyd/default.conf}
  '';

  home.activation.setupAlacritty = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../scripts/setup-alacritty.sh} \
      ${alacrittyGL}
  '';

  home.activation.setupZsh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../scripts/setup-zsh.sh} \
      ${config.home.profileDirectory}/bin/zsh \
      ${user}
  '';

  # docker installed from Docker's official apt repo (not nix — the daemon
  # needs root/systemd/networking that's painful to run from /nix/store on a
  # non-NixOS host). /usr/sbin is on PATH for usermod/groupadd.
  home.activation.setupDocker = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/sbin:/sbin:/usr/bin:/bin:$PATH
    ${../scripts/setup-docker.sh} \
      ${user}
  '';
}
