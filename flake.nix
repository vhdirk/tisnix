{
  description = "@vhdirk's nix packages";

  outputs = {
    nixpkgs,
    flake-parts,
    devenv,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
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
        # packages.pam-any = pkgs.callPackage ./pam-any {};
        # packages.pam-random = pkgs.callPackage ./pam-random {};
        # packages.pam-fprint-grosshack = pkgs.callPackage ./pam-fprint-grosshack {};

        # packages.spotify-adblock = pkgs.callPackage ./spotify-adblock {};

        # packages.linux-dynamic-wallpapers = pkgs.callPackage ./linux-dynamic-wallpapers {};

        # packages.zsh4humans = pkgs.callPackage ./zsh4humans {};

        devenv.shells.default = {
          packages = with pkgs; [go-task just];
        };
      };
    });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    devenv = {
      url = "github:cachix/devenv";
    };
  };
}
