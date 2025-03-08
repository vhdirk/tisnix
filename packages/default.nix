{final, prev, ...}: {
  ## packages
  pam-any = prev.callPackage ./pam-any {};
  pam-random = prev.callPackage ./pam-random {};
  pam-fprint-grosshack = prev.callPackage ./pam-fprint-grosshack {};

  spotify-adblock = prev.callPackage ./spotify-adblock {};

  linux-dynamic-wallpapers = prev.callPackage ./linux-dynamic-wallpapers {};

  zsh4humans = prev.callPackage ./zsh4humans {};

  uniffi-bindgen = prev.callPackage ./uniffi-bindgen {};


  ## overrides

  # gnomeExtensions =
  # prev.gnomeExtensions
  # // import ./gnome-shell-extensions {inherit prev final;};

  # libfprint = import ./libfprint-cs9711 {inherit prev final; };

  # gnome-keyring = import ./gnome-keyring  {inherit prev final; };

}
