{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  clang,
  pam,
  pkgs,
  cargo,
  rustc,
  llvmPackages,
}:
rustPlatform.buildRustPackage rec {
  pname = "pam-random";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ChocolateLoverRaj";
    repo = "pam-random";
    rev = "master";
    sha256 = "4K4KAbAXUmVlugUfpPp7d2OXQUFhW5GiWKORE/nOnWo=";
  };

  cargoHash = "sha256-RdeOv3gkfxgE3GLhOFb+mapQ5m//lSvYOLQ8oxT+vNw=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    cargo
    rustc
    clang
    llvmPackages.libclang
    pkgs.tree
  ];

  buildInputs = [
    pam
  ];

  installPhase = ''
    tree .
    mkdir -p $out/lib/security
    cp target/x86_64-unknown-linux-gnu/release/libpam_random.so $out/lib/security/pam_random.so
  '';

  meta = with lib; {
    description = "Linux PAM library written in Rust";
    homepage = "https://github.com/ChocolateLoverRaj/pam-random";
    license = licenses.mit; # Verify the actual license
    maintainers = []; # Add yourself if you want
    platforms = platforms.linux;
  };
}
