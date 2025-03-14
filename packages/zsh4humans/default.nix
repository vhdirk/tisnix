{
  lib,
  stdenv,
  pkg-config,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "zsh4humans";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "vhdirk";
    repo = "zsh4humans";
    rev = "v5";
    hash = "sha256-ie8amOuQGzvPgoldcKbgKH1SozyiIzOECPyjWh6E358=";
  };

  dontBuild = true;

  installPhase = ''
    # Create the output directory
    mkdir -p $out/share
    cp -r $src $out/share/zsh4humans
  '';

  meta = with lib; {
    description = "Zsh for Humans";
    homepage = "https://github.com/romkatv/zsh4humans/";
    license = licenses.mit; # Adjust the license accordingly
    platforms = platforms.unix;
    maintainers = with maintainers; [
      # add yourself
    ];
  };
}
