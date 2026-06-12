{
  description = "awalvie's boomer dotfiles (Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixGL: wraps GUI apps so nix-built binaries find the host GPU driver on
    # non-NixOS. Required for GL/EGL apps (alacritty) on this NVIDIA host.
    # Intentionally NOT following our nixpkgs — its own pin is what the
    # confirmed `nix run github:nix-community/nixGL` used.
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
      user   = builtins.getEnv "USER";
    in
    {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit user nixgl; };
        modules = [ ./nix/home.nix ];
      };
    };
}
