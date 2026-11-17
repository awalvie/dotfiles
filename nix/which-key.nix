# wlr-which-key on Mod+Space: a menu of niri actions that doubles as a cheat
# sheet. The menu is generated from niri's key binds at `hms` time
# (scripts/niri-which-key.py), so it always matches them; each label shows the
# direct shortcut. No GPU use, so it comes from nix (ADR 0001).
{ pkgs, ... }:

{
  home.packages = [ pkgs.wlr-which-key ];

  xdg.configFile."wlr-which-key/config.yaml".source =
    pkgs.runCommand "wlr-which-key-config" { } ''
      ${pkgs.python3}/bin/python3 -I ${../scripts/niri-which-key.py} \
        ${../config/niri/cfg/keybinds.kdl} > $out
    '';
}
