{ config, pkgs, lib, user, ... }:

{
  imports = [ ./common.nix ];

  # alacritty runs natively on macos — no nixGL wrap needed. pbcopy/pbpaste are
  # built in, so no clipboard package. keyd is linux-only (use Karabiner on mac).
  home.packages = with pkgs; [
    alacritty
  ];

  # hms targets the darwin config. no NIXPKGS_ALLOW_UNFREE (nothing unfree here —
  # that was only the nixGL NVIDIA driver on linux); --impure still needed for
  # the flake's builtins.getEnv "USER".
  programs.zsh.shellAliases = {
    hms = "home-manager switch --flake ~/dotfiles#darwin --impure";
  };
}
