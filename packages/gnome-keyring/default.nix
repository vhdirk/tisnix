{
  prev,
  final,
  lib,
  libgcrypt,
  openssh,
  ...
}:
prev.gnome-keyring.overrideAttrs (oldAttrs: {
  configureFlags = [
    "--with-pkcs11-config=${placeholder "out"}/etc/pkcs11/" # installation directories
    "--with-pkcs11-modules=${placeholder "out"}/lib/pkcs11/"
    # cross compilation requires these paths to be explicitly declared:
    "LIBGCRYPT_CONFIG=${lib.getExe' (lib.getDev libgcrypt) "libgcrypt-config"}"
    "SSH_ADD=${lib.getExe' openssh "ssh-add"}"
    "SSH_AGENT=${lib.getExe' openssh "ssh-agent"}"
  ];
})
