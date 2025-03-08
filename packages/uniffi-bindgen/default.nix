{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ktlint,
  yapf,
  rubocop,
  rustfmt,
  makeWrapper,
  pkg-config,
  clang,
  cargo,
  rustc,
  llvmPackages,
}:
rustPlatform.buildRustPackage rec {
  pname = "uniffi-bindgen";
  version = "0.28.3";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "uniffi-rs";
    rev = "v${version}";
    sha256 = "A6Zd1jfhoR4yW2lT5qYE3vJTpiJc94pK/XQmfE2QLFc=";
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
    makeWrapper
  ];

  # buildInputs = [
  #   pam
  # ];

  # installPhase = ''
  #   mkdir -p $out/lib/security
  #   cp target/x86_64-unknown-linux-gnu/release/libpam_any.so $out/lib/security/pam_any.so
  # '';

  cargoBuildFlags = ["-p uniffi_bindgen"];
  cargoTestFlags = ["-p uniffi_bindgen"];

  postFixup = ''
    wrapProgram "$out/bin/uniffi-bindgen" \
      --suffix PATH : ${lib.strings.makeBinPath [rustfmt ktlint yapf rubocop]}
  '';

  meta = with lib; {
    description = "Toolkit for building cross-platform software components in Rust";
    homepage = "https://mozilla.github.io/uniffi-rs/";
    license = licenses.mpl20;
    maintainers = with maintainers; [vtuan10];
  };
}
