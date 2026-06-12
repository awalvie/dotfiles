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
    # Not used on darwin. Follows our nixpkgs so we don't fetch/eval a second,
    # stale nixpkgs just for the wrapper (nixGL detects the driver at runtime).
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      user = builtins.getEnv "USER";

      mkHome = { system, modules, extraArgs ? { } }:
        home-manager.lib.homeManagerConfiguration {
          # import (not legacyPackages) so we can scope the unfree allowance to
          # just the nixGL NVIDIA driver instead of a blanket NIXPKGS_ALLOW_UNFREE.
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = p:
              nixpkgs.lib.hasPrefix "nvidia" (nixpkgs.lib.getName p);
          };
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
