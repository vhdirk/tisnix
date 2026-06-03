{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "zsh4humans";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "romkatv";
    repo = "zsh4humans";
    rev = "c0c29f9";
    hash = "sha256-yha/ITOHDlAZDg1GHjLeeK10UCtwmhTeDkXQaANrF78=";
  };

  dontBuild = true;

  installPhase = ''
\    mkdir -p $out/share
    cp -r $src $out/share/zsh4humans
  '';

  meta = with lib; {
    description = "Zsh for Humans";
    homepage = "https://github.com/romkatv/zsh4humans/";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [
      # add yourself
    ];
  };
}
