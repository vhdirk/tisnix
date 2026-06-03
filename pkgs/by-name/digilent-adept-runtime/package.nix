{
  lib,
  stdenv,
  fetchurl,
  rpm,
  cpio,
  autoPatchelfHook,
  udev,
  libusb1,
  avahi
}:

stdenv.mkDerivation rec {
  pname = "digilent-adept-runtime";
  version = "2.30.1";

  src = fetchurl {
    url = "https://files.digilent.com/Software/Adept2%20Runtime/${version}/digilent.adept.runtime_${version}_x86_64.rpm";
    hash = "sha256-G1i2YUO13hLVhrN55MH4pCK/b/zafiBmWT5NgVixP5I=";
  };

  nativeBuildInputs = [
    rpm
    cpio
    autoPatchelfHook
  ];

  buildInputs = [
    udev
    libusb1
    avahi
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    rpm2cpio ${src} | cpio -idmv
  '';

  installPhase = ''
    # Libraries
    mkdir -p $out/lib/digilent/adept
    cp -r usr/lib/digilent/adept/*.so* $out/lib/

    # udev helper binary
    mkdir -p $out/lib/udev
    cp usr/lib/udev/dftdrvdtch $out/lib/udev/

    # Data files (firmware, maps, etc.)
    mkdir -p $out/share/digilent
    cp -r usr/share/digilent/adept $out/share/digilent/

    # Docs
    mkdir -p $out/share/doc
    cp -r usr/share/doc/digilent.adept.runtime $out/share/doc/

    # Config file
    mkdir -p $out/etc
    cp etc/digilent-adept.conf $out/etc/
  '';

  postFixup = ''
    chmod -x $out/share/digilent/adept/data/firmware/*.so || true
    patchelf --set-rpath "$out/lib/digilent/adept" $out/lib/udev/dftdrvdtch || true
  '';

  meta = with lib; {
    description = "Digilent Adept Runtime - USB device communication libraries";
    homepage = "https://digilent.com/reference/software/adept/start";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
