{pkgs, ...} @inputs: {
  ## packages
  pam-any = pkgs.callPackage ./pam-any {};
  pam-random = pkgs.callPackage ./pam-random {};
  pam-fprint-grosshack = pkgs.callPackage ./pam-fprint-grosshack {};

  spotify-adblock = pkgs.callPackage ./spotify-adblock {};

  linux-dynamic-wallpapers = pkgs.callPackage ./linux-dynamic-wallpapers {};

  zsh4humans = pkgs.callPackage ./zsh4humans {};


  tp_smapi = pkgs.callPackage ./tp_smapi {};
}
