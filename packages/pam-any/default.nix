{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  clang,
  pam,
  cargo,
  rustc,
  llvmPackages,
}:
rustPlatform.buildRustPackage rec {
  pname = "pam-any";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "ChocolateLoverRaj";
    repo = "pam-any";
    rev = "main";
    sha256 = "em/vifkse1Qp3iX/oE1vHQK6UAoJvbhBOowhFhgQ+qw=";
  };

  cargoHash = "sha256-xHF2jYXQ6Ysu93NaJ+dvJERkxCX1spdM83aPF7ZWyns=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    cargo
    rustc
    clang
    llvmPackages.libclang
  ];

  buildInputs = [
    pam
  ];

  installPhase = ''
    mkdir -p $out/lib/security
    cp target/x86_64-unknown-linux-gnu/release/libpam_any.so $out/lib/security/pam_any.so
  '';

  meta = with lib; {
    description = "Linux PAM library written in Rust";
    homepage = "https://github.com/ChocolateLoverRaj/pam-any";
    license = licenses.mit; # Verify the actual license
    maintainers = []; # Add yourself if you want
    platforms = platforms.linux;
  };
}
