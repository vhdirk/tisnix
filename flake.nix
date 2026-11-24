{
  description = "@vhdirk's nix packages";

  outputs =
    {
      nixpkgs,
      flake-parts,
      devenv,
      pkgs-by-name-for-flake-parts,
      treefmt-nix,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        ...
      }:
      {
        imports = [
          pkgs-by-name-for-flake-parts.flakeModule
          flake-parts.flakeModules.easyOverlay
          devenv.flakeModule
          treefmt-nix.flakeModule
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

          overlays = rec {
            tisnix = inputs.self.overlays.default;
            default = tisnix;
          };

        };

        systems = nixpkgs.lib.systems.flakeExposed;

        perSystem =
          {
            config,
            ...
          }:
          {
            pkgsDirectory = ./packages;
            overlayAttrs = config.legacyPackages;

            treefmt = {
              projectRootFile = "flake.nix";
              programs = {
                nixfmt.enable = true;
                shellcheck.enable = true;
              };
            };

            devenv.shells.default = {
            };
          };
      }
    );

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    devenv.url = "github:cachix/devenv";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
