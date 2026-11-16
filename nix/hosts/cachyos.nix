# CachyOS (niri + Noctalia) work PC. Shared Linux config lives in linux.nix.
{ ... }:

{
  imports = [ ../linux.nix ];

  programs.zsh.shellAliases.hms =
    "home-manager switch --flake ~/dotfiles#cachyos --impure";
}
