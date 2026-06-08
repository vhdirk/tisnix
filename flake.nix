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
        withSystem,
        ...
      }:
      {
        imports = [
          pkgs-by-name-for-flake-parts.flakeModule
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

          overlays.default = final: prev: {
            local = withSystem prev.stdenv.hostPlatform.system ({ config, ... }: config.packages);
            libsigrok = prev.libsigrok.overrideAttrs (old: {
              src = final.fetchFromGitHub {
                owner = "huehuehuehueing";
                repo = "libsigrok";
                rev = "11bf53b39154b5ed035181c7b8017e5146a1e73e";
                hash = "sha256-u94VDwYZw8K+QLaSGgY7nSbefQy/ESZ3hvR3GCO66EM=";
              };
            });
          };

        };

        # systems = nixpkgs.lib.systems.flakeExposed;

        perSystem =
          {
            ...
          }:
          {
            pkgsDirectory = ./packages;

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
