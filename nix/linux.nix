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
