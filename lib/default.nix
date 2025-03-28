{lib, ...}: {
  toBase64 = import ./base64.nix { inherit lib ; };
}