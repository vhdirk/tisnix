{
  description = "@vhdirk's nix packages";

  outputs = {
    nixpkgs,
    flake-parts,
    devenv,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [
        flake-parts.flakeModules.easyOverlay
        devenv.flakeModule
      ];

      flake = {
        homeManagerModules = rec {
          tisnix = import ./modules/home-manager;
          default = tisnix;
        };

        nixosModules = rec {
          tisnix = import ./modules/nixos;
          default = tisnix;
        };

        darwinModules = rec {
          tisnix = import ./modules/darwin;
          default = tisnix;
        };
      };

      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        overlayAttrs = {
          inherit (config.packages) pam-any pam-random pam-fprint-grosshack spotify-adblock linux-dynamic-wallpapers zsh4humans;
        };

        formatter = pkgs.alejandra;

        packages = import ./packages {inherit pkgs;};

        devenv.shells.default = {
        };
      };
    });

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    devenv = {
      url = "github:cachix/devenv";
    };
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
