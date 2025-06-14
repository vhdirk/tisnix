{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  kernel,
  writeScript,
  coreutils,
  gnugrep,
  jq,
  curl,
  common-updater-scripts,
  runtimeShell,
}:

stdenv.mkDerivation rec {
  name = "tp_smapi-${version}-${kernel.version}";
  version = "0.43";

  src = fetchFromGitHub {
    owner = "linux-thinkpad";
    repo = "tp_smapi";
    rev = "tp-smapi/${version}";
    sha256 = "1rjb0njckczc2mj05cagvj0lkyvmyk6bw7wkiinv81lw8m90g77g";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  hardeningDisable = [ "pic" ];

  makeFlags = [
    "KBASE=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
    "SHELL=${stdenv.shell}"
    "HDAPS=1"
  ];

  installPhase = ''
    install -v -D -m 644 thinkpad_ec.ko "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/firmware/thinkpad_ec.ko"
    install -v -D -m 644 tp_smapi.ko "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/firmware/tp_smapi.ko"
    install -v -D -m 644 hdaps.ko "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/firmware/hdapsd.ko"
  '';

  dontStrip = true;

  enableParallelBuilding = true;

  passthru.updateScript = import ./update.nix {
    inherit
      lib
      writeScript
      coreutils
      gnugrep
      jq
      curl
      common-updater-scripts
      runtimeShell
      ;
  };

  meta = {
    description = "IBM ThinkPad hardware functions driver";
    homepage = "https://github.com/linux-thinkpad/tp_smapi";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    # driver is only meant for linux thinkpads i think  bellow platforms should cover it.
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}