{
  prev,
  final,
  ...
}: let
  lib = prev.lib;
in
  prev.gnome-keyring.overrideAttrs (oldAttrs: {
    configureFlags = [
      "--with-pkcs11-config=${placeholder "out"}/etc/pkcs11/" # installation directories
      "--with-pkcs11-modules=${placeholder "out"}/lib/pkcs11/"
      # cross compilation requires these paths to be explicitly declared:
      "LIBGCRYPT_CONFIG=${lib.getExe' (lib.getDev final.libgcrypt) "libgcrypt-config"}"
      "SSH_ADD=${lib.getExe' final.openssh "ssh-add"}"
      "SSH_AGENT=${lib.getExe' final.openssh "ssh-agent"}"
    ];
  })
