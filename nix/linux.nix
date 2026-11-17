{ config, pkgs, lib, user, ... }:

# Shared by every Linux host (pop, cachyos). Host modules import this.
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    wl-clipboard
    xclip
    fontconfig
    xdg-utils      # xdg-open, used by the `o` alias
  ];

  fonts.fontconfig.enable = true;

  programs.zsh.shellAliases.xclip = "xclip -selection clipboard";

  # tsp / tsw: switch Tailscale to the account nicknamed personal / work.
  # Without that nickname on this machine, print how to set it up.
  programs.zsh.initContent = ''
    function _ts_switch {
      tailscale switch "$1" && return
      print -u2 "
    No Tailscale account nicknamed '$1' here. Set it up once:
      tailscale switch --list                  # find the account
      tailscale switch <account>               # or: tailscale login, for a new one
      sudo tailscale set --operator=\$USER --nickname=$1"
      return 1
    }
    function tsp { _ts_switch personal }
    function tsw { _ts_switch work }
  '';

  home.activation.setupZsh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../scripts/setup-zsh.sh} \
      ${config.home.profileDirectory}/bin/zsh \
      ${user}
  '';

  # Firefox comes from the host OS; its policy file sets our extensions and
  # defaults (see scripts/setup-firefox.sh).
  home.activation.setupFirefox = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=/usr/bin:/bin:$PATH
    ${../scripts/setup-firefox.sh} ${../home/firefox/policies.json}
  '';
}
