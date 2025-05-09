{pkgs, ...} @inputs: {
  ## packages
  pam-any = pkgs.callPackage ./pam-any {};
  pam-random = pkgs.callPackage ./pam-random {};
  pam-fprint-grosshack = pkgs.callPackage ./pam-fprint-grosshack {};

  spotify-adblock = pkgs.callPackage ./spotify-adblock {};

  linux-dynamic-wallpapers = pkgs.callPackage ./linux-dynamic-wallpapers {};

  zsh4humans = pkgs.callPackage ./zsh4humans {};


  ## overrides

  # gnomeExtensions =
  # prev.gnomeExtensions
  # // import ./gnome-shell-extensions {inherit prev final;};

  # libfprint = import ./libfprint-cs9711 {inherit prev final; };
  # gnome-keyring = import ./gnome-keyring inputs;

  franz = pkgs.callPackage ./franz {};
  ferdium = pkgs.callPackage ./ferdium {};
}
