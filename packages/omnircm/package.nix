{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  makeDesktopItem,
  copyDesktopItems,
  # Runtime dependencies
  libusb1,
  libX11,
  libICE,
  libSM,
  libXcursor,
  libXext,
  libXi,
  libXrandr,
  libXrender,
  fontconfig,
  libGL,
}:

buildDotnetModule (finalAttrs: {
  pname = "omnircm";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "DefenderOfHyrule";
    repo = "OmniRCM";
    rev = "v${finalAttrs.version}";
    hash = "sha256-u3xeBibPUTepAl3SZpuSI2s4y8pU60zlMCO5p7FHzMQ=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  projectFile = "OmniRCM.csproj";
  nugetDeps = ./deps.json;

  executables = [ "OmniRCM" ];

  nativeBuildInputs = [
    copyDesktopItems
  ];

  runtimeDeps = [
    libusb1
    # Avalonia UI dependencies
    libX11
    libICE
    libSM
    libXcursor
    libXext
    libXi
    libXrandr
    libXrender
    fontconfig
    libGL
  ];

  postInstall = ''
    # Application icons
    install -D -m 644 Assets/icon.png $out/share/icons/hicolor/512x512/apps/omnircm.png
    install -D -m 644 Assets/icon.png $out/share/pixmaps/omnircm.png

    # Udev rules for Nintendo Switch in RCM mode
    install -d $out/lib/udev/rules.d
    cat > $out/lib/udev/rules.d/70-omnircm.rules << 'EOF'
# Nintendo Switch RCM (Recovery Mode) / NVIDIA APX
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", MODE="0660", TAG+="uaccess"
SUBSYSTEMS=="usb", ATTRS{manufacturer}=="NVIDIA Corp.", ATTRS{product}=="APX", MODE="0660", TAG+="uaccess"
EOF
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "omnircm";
      desktopName = "OmniRCM";
      comment = "Nintendo Switch RCM payload injector";
      exec = "omnircm";
      icon = "omnircm";
      categories = [
        "Utility"
      ];
      startupNotify = true;
    })
  ];

  postFixup = ''
    mv $out/bin/OmniRCM $out/bin/omnircm
  '';

  meta = {
    description = "Universal Nintendo Switch RCM payload injector";
    homepage = "https://github.com/DefenderOfHyrule/OmniRCM";
    license = lib.licenses.gpl3Plus;
    mainProgram = "omnircm";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
