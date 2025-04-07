{
  description = "@vhdirk's nix packages";

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }: let
    packages = import ./packages;

    # TODO: lib doesn't actually seem to work
    overlay = final: prev: packages {inherit final prev;} // { lib = prev.lib // import ./lib { lib = prev.lib;}; };
  in {
    formatter = flake-utils.lib.eachDefaultSystemPassThrough (system: {
      "${system}" = {pkgs}: pkgs.alejandra;
    });

    overlays = {
      default = overlay;
      tisnix = overlay;
    };

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

    packages = flake-utils.lib.eachDefaultSystemPassThrough (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      "${system}" = packages {
        final = pkgs;
        prev = pkgs;
      };
    });

    devShells = flake-utils.lib.eachDefaultSystemPassThrough (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      "${system}".default = pkgs.mkShell {
        packages = with pkgs; [go-task just];
      };
    });
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # add git hooks to format nix code before commit
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {url = "github:numtide/flake-utils";};
  };
}
