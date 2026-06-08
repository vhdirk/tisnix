{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "sigrok-firmware-dreamsourcelab-dslogic";
  src = pkgs.fetchFromGitHub {
    owner = "DreamSourceLab";
    repo = "DSView";
    rev = "2e9e2c8e726df4ef5687d39b83d4f797cc44b574";
    sha256 = "sha256-F7T3wEasIzfhQXVaU8MVo06h3RB1nhWxkp2sUb8Ct80=";
  };
  installPhase = ''
    mkdir -p $out/share/sigrok-firmware
    cd DSView

    # DSLogic
    cp res/DSLogic50.bin  $out/share/sigrok-firmware/dreamsourcelab-dslogic-fpga-5v.fw
    cp res/DSLogic33.bin  $out/share/sigrok-firmware/dreamsourcelab-dslogic-fpga-3v3.fw
    cp res/DSLogic.fw     $out/share/sigrok-firmware/dreamsourcelab-dslogic-fx2.fw

    # DScope
    cp res/DSCope.bin $out/share/sigrok-firmware/dreamsourcelab-dscope-fpga.fw
    cp res/DSCope.fw  $out/share/sigrok-firmware/dreamsourcelab-dscope-fx2.fw

    # DSLogic Pro
    cp res/DSLogicPro.bin $out/share/sigrok-firmware/dreamsourcelab-dslogic-pro-fpga.fw
    cp res/DSLogicPro.fw  $out/share/sigrok-firmware/dreamsourcelab-dslogic-pro-fx2.fw

    # DSLogic Plus
    cp res/DSLogicPlus-pgl12-2.bin  $out/share/sigrok-firmware/dreamsourcelab-dslogic-plus-fpga.fw
    # cp res/DSLogicPlus.fw 	        $out/share/sigrok-firmware/dreamsourcelab-dslogic-plus-fx2.fw

    # DSLogic Basic
    cp res/DSLogicBasic.bin $out/share/sigrok-firmware/dreamsourcelab-dslogic-basic-fpga.fw
    cp res/DSLogicBasic.fw  $out/share/sigrok-firmware/dreamsourcelab-dslogic-basic-fx2.fw

    mkdir -p $out/lib/udev/rules.d
    cp DreamSourceLab.rules $out/lib/udev/rules.d/
  '';
  dontBuild = true;
}
