{
  lib,
  stdenv,
  fetchurl,
  rpm,
  cpio,
  autoPatchelfHook,
  udev,
  libusb1,
  avahi,
  qt6,
  digilent-adept-runtime,
}:

stdenv.mkDerivation rec {
  pname = "digilent-waveforms";
  version = "3.25.1";

  src = fetchurl {
    url = "https://files.digilent.com/Software/Waveforms/${version}/digilent.waveforms_${version}.x86_64.rpm";
    hash = "sha256-N3UBcJj+tWFpF4H0G4OSA+ZCZQBm3vIjnf4P1xgxInY=";
  };

  nativeBuildInputs = [
    rpm
    cpio
    autoPatchelfHook
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    udev
    stdenv.cc.cc.lib
    libusb1
    avahi
    qt6.qtbase
    qt6.qtwayland
    qt6.qtmultimedia
    qt6.qtdeclarative
    qt6.qtnetworkauth
    qt6.qtserialport
    digilent-adept-runtime
  ];

  unpackPhase = ''
    rpm2cpio ${src} | cpio -idmv
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp usr/bin/waveforms $out/bin/
    cp usr/bin/dwfcmd $out/bin/

    mkdir -p $out/lib
    cp usr/lib/libdwf.so* $out/lib/

    mkdir -p $out/include/digilent/waveforms
    cp usr/include/digilent/waveforms/dwf.h $out/include/digilent/waveforms/

    mkdir -p $out/share/digilent
    cp -r usr/share/digilent/waveforms $out/share/digilent/

    mkdir -p $out/share/applications
    cp usr/share/applications/digilent.waveforms.desktop $out/share/applications/

    mkdir -p $out/share/man/man1
    cp usr/share/man/man1/*.gz $out/share/man/man1/

    mkdir -p $out/share/mime/packages
    cp usr/share/mime/packages/digilent.waveforms.xml $out/share/mime/packages/

    mkdir -p $out/share/doc
    cp -r usr/share/doc/digilent.waveforms $out/share/doc/
  '';

  # Fix the desktop file to point to the Nix store icon
  postInstall = ''
    substituteInPlace $out/share/applications/digilent.waveforms.desktop \
      --replace "Icon=digilent.waveforms" \
                "Icon=$out/share/digilent/waveforms/pixmaps/256.png"
  '';

  meta = with lib; {
    description = "Digilent WaveForms - oscilloscope/logic analyzer application";
    homepage = "https://digilent.com/reference/software/waveforms/waveforms-3/start";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
