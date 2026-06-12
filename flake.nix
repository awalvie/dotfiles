{
  description = "awalvie's boomer dotfiles (Linux + macOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixGL: wraps GUI apps so nix-built binaries find the host GPU driver on
    # non-NixOS Linux. Required for GL/EGL apps (alacritty) on the NVIDIA host.
    # Not used on darwin. Intentionally NOT following our nixpkgs — its own pin
    # is what the confirmed `nix run github:nix-community/nixGL` used.
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      user = builtins.getEnv "USER";

      mkHome = { system, modules, extraArgs ? { } }:
        home-manager.lib.homeManagerConfiguration {
          pkgs             = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit user; } // extraArgs;
          inherit modules;
        };
    in
    {
      homeConfigurations = {
        # Linux (COSMIC/PopOS, NVIDIA). `hms` -> #default
        default = mkHome {
          system    = "x86_64-linux";
          modules   = [ ./nix/linux.nix ];
          extraArgs = { inherit nixgl; };
        };

        # Intel macOS. `hms` -> #darwin
        darwin = mkHome {
          system  = "x86_64-darwin";
          modules = [ ./nix/darwin.nix ];
        };
      };
    };
}
