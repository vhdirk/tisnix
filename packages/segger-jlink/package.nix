{
  lib,
  stdenv,
  runCommand,
  curl,
  cacert,
  callPackage,
  autoPatchelfHook,
  python3,
  cpio,
  gzip,
  makeWrapper,
  rsync,
  xar,
  udev,
  config,
  acceptLicense ? config.segger-jlink.acceptLicense or false,
  headless ? false,
  makeDesktopItem,
  copyDesktopItems,
}:

let
  source = import ./source.nix;
  supported = removeAttrs source [ "version" ];

  platform = supported.${stdenv.system} or (throw "unsupported platform ${stdenv.system}");

  inherit (source) version;

  url = "https://www.segger.com/downloads/jlink/JLink_${platform.os}_V${version}_${platform.name}.${platform.ext}";

  src =
    assert
      !acceptLicense
      -> throw ''
        Use of the "SEGGER JLink Software and Documentation pack" requires the
        acceptance of the following licenses:

          - SEGGER Downloads Terms of Use [1]
          - SEGGER Software Licensing [2]

        You can express acceptance by setting acceptLicense to true in your
        configuration. Note that this is not a free license so it requires allowing
        unfree licenses as well.

        configuration.nix:
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.segger-jlink.acceptLicense = true;

        config.nix:
          allowUnfree = true;
          segger-jlink.acceptLicense = true;

        [1]: ${url}
        [2]: https://www.segger.com/purchase/licensing/
      '';
    runCommand "JLink_${platform.os}_V${version}_${platform.name}.${platform.ext}"
      {
        outputHash = platform.hash;
        outputHashMode = "flat";
        nativeBuildInputs = [
          curl
          cacert
        ];
      }
      ''
        curl --fail --location \
          --data "accept_license_agreement=accepted" \
          --user-agent "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:51.0) Gecko/20100101 Firefox/51.0" \
          "${url}" \
          --output "$out"
      '';

  qt4-bundled = callPackage ./qt4-bundled.nix { inherit src version; };

  buildAttrsLinux = {
    nativeBuildInputs = [
      autoPatchelfHook
      python3
    ]
    ++ lib.optionals (!headless) [
      copyDesktopItems
    ];

    buildInputs = lib.optionals (!headless) [
      qt4-bundled
    ];

    # Udev is loaded late at runtime
    appendRunpaths = [
      "${udev}/lib"
    ];

    desktopItems = lib.optionals (!headless) (
      map
        (
          entry:
          (makeDesktopItem {
            name = entry;
            exec = entry;
            icon = "applications-utilities";
            desktopName = entry;
            genericName = "SEGGER ${entry}";
            categories = [ "Development" ];
            type = "Application";
            terminal = false;
            startupNotify = false;
          })
        )
        [
          "JFlash"
          "JFlashLite"
          "JFlashSPI"
          "JLinkConfig"
          "JLinkGDBServer"
          "JLinkLicenseManager"
          "JLinkRTTViewer"
          "JLinkRegistration"
          "JLinkRemoteServer"
          "JLinkSWOViewer"
          "JLinkUSBWebServer"
          "JMem"
        ]
    );

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/SEGGER/JLink

      ${lib.optionalString (!headless) ''
        # Install binaries and runtime files into /opt/SEGGER/JLink
        mv J* ETC GDBServer Firmwares $out/opt/SEGGER/JLink

        # Link executables into /bin/
        mkdir -p $out/bin
        for binr in $out/opt/SEGGER/JLink/*Exe; do
          binrlink=''${binr#"$out/opt/SEGGER/JLink/"}
          ln -s $binr $out/bin/$binrlink
          # Create additional symlinks without "Exe" suffix
          binrlink=''${binrlink/%Exe}
          ln -s $binr $out/bin/$binrlink
        done

        # Copy special alias symlinks
        for slink in $(find $out/opt/SEGGER/JLink/. -type l); do
          cp -P -n $slink $out/bin || true
          rm $slink
        done
      ''}

      # Install libraries
      install -Dm444 libjlinkarm.so* -t $out/lib
      for libr in $out/lib/libjlinkarm.*; do
        ln -s $libr $out/opt/SEGGER/JLink
      done

      # Install docs and examples
      mkdir -p $out/share
      mv Doc $out/share/docs
      mv Samples $out/share/examples

      # Install udev rules
      install -Dm444 99-jlink.rules -t $out/lib/udev/rules.d/

      runHook postInstall
    '';

    preFixup = ''
      # Patchelf resizes .dynamic in the executables and places it in a read-only PT_LOAD segment.
      # Glibc 2.44+ unconditionally writes to DT_DEBUG in dl_main, which causes a SIGSEGV
      # if the PT_LOAD segment containing PT_DYNAMIC is marked PF_R (read-only) rather than PF_W (writable).
      # Here we ensure that any PT_LOAD segment containing PT_DYNAMIC has the write bit set.
      fixSegmentPermissions() {
        echo "Fixing PT_LOAD permissions for PT_DYNAMIC sections..."
        python3 -c '
import os, struct

def fix_elf(path):
    try:
        with open(path, "r+b") as f:
            if f.read(4) != b"\x7fELF":
                return
            ei_class = f.read(1)[0]
            if ei_class == 1:
                f.seek(28)
                phoff = struct.unpack("<I", f.read(4))[0]
                f.seek(42)
                phentsize = struct.unpack("<H", f.read(2))[0]
                phnum = struct.unpack("<H", f.read(2))[0]
                dynamic_addr = None
                for i in range(phnum):
                    f.seek(phoff + i * phentsize)
                    p_type, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_flags, p_align = struct.unpack("<IIIIIIII", f.read(32))
                    if p_type == 2:
                        dynamic_addr = p_vaddr
                        break
                if dynamic_addr is not None:
                    for i in range(phnum):
                        f.seek(phoff + i * phentsize)
                        p_type, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_flags, p_align = struct.unpack("<IIIIIIII", f.read(32))
                        if p_type == 1 and (p_vaddr <= dynamic_addr < p_vaddr + p_memsz):
                            if not (p_flags & 2):
                                new_flags = p_flags | 2
                                f.seek(phoff + i * phentsize + 24)
                                f.write(struct.pack("<I", new_flags))
                                print(f"Fixed {path} (32-bit): flags {p_flags} -> {new_flags}")
            elif ei_class == 2:
                f.seek(32)
                phoff = struct.unpack("<Q", f.read(8))[0]
                f.seek(54)
                phentsize = struct.unpack("<H", f.read(2))[0]
                phnum = struct.unpack("<H", f.read(2))[0]
                dynamic_addr = None
                for i in range(phnum):
                    f.seek(phoff + i * phentsize)
                    p_type, p_flags, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_align = struct.unpack("<IIQQQQQQ", f.read(56))
                    if p_type == 2:
                        dynamic_addr = p_vaddr
                        break
                if dynamic_addr is not None:
                    for i in range(phnum):
                        f.seek(phoff + i * phentsize)
                        p_type, p_flags, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_align = struct.unpack("<IIQQQQQQ", f.read(56))
                        if p_type == 1 and (p_vaddr <= dynamic_addr < p_vaddr + p_memsz):
                            if not (p_flags & 2):
                                new_flags = p_flags | 2
                                f.seek(phoff + i * phentsize + 4)
                                f.write(struct.pack("<I", new_flags))
                                print(f"Fixed {path} (64-bit): flags {p_flags} -> {new_flags}")
    except Exception as e:
        pass

for root, dirs, files in os.walk("'"$out"'"):
    for file in files:
        fix_elf(os.path.join(root, file))
'
      }
      postFixupHooks+=(fixSegmentPermissions)
    '';
  };

  buildAttrsDarwin = {
    nativeBuildInputs = [
      cpio
      gzip # gunzip
      makeWrapper
      rsync
      xar
    ];

    unpackPhase = ''
      runHook preUnpack

      xar -xf $src

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      # segger package
      mkdir JLINK
      pushd JLINK
      cat ../JLink.pkg/Payload | gunzip -dc | cpio -i
      rsync -rtl ./Applications $out/
      popd

      # By default, the package unpacks a symlink to an absolute path:
      # JLink -> /Applications/SEGGER/JLink_V824
      # ... replace with a relative symlink to the package contents themselves.
      ln -rsf $out/Applications/SEGGER/{JLink_V${version},JLink}

      # autoPatchelfHook is broken, manually wrap binaries before linking them into $out/bin
      LDPATH=$out/Applications/SEGGER/JLink_V${version}
      mkdir -p $out/bin
      find $out -type f -executable ! -name "*.dylib" -print0 | while read -d $'\0' e; do
        wrapProgram "$e" --set LD_LIBRARY_PATH $LDPATH --set DYLD_LIBRARY_PATH $LDPATH
        ln -rs "$e" $out/bin/
      done

      runHook postInstall
    '';

  };

  buildAttrs =
    if stdenv.hostPlatform.isLinux then
      buildAttrsLinux
    else if stdenv.hostPlatform.isDarwin then
      buildAttrsDarwin
    else
      throw "platform not supported";

in
stdenv.mkDerivation (
  finalAttrs:
  buildAttrs
  // {
    pname = "segger-jlink";
    inherit src version;

    dontConfigure = true;
    dontBuild = true;

    passthru.updateScript = ./update.py;

    meta = {
      description = "J-Link Software and Documentation pack";
      homepage = "https://www.segger.com/downloads/jlink/#J-LinkSoftwareAndDocumentationPack";
      changelog = "https://www.segger.com/downloads/jlink/ReleaseNotes_JLink.html";
      license = lib.licenses.unfree;
      platforms = lib.attrNames supported;
      maintainers = with lib.maintainers; [
        FlorianFranzen
        h7x4
        stargate01
      ];
    };
  }
)
