{
  lib,
  stdenv,
  wallpapers ? [
    "Adwaita"
    "AnimeRoomBoard"
    "Aura"
    "BigSur"
    "BigSurV2"
    "Blobs"
    "Carvan"
    "Catalina"
    "CatherineRoom"
    "ChromeOSBlues"
    "ChromeOSEarth"
    "ChromeOSFire"
    "ChromeOSGreens"
    "ChromeOSReds"
    "ChromeOSWater"
    "ChromeOSWind"
    "ChromeOSYellows"
    "Coast"
    "CorporationHall"
    "CorporationStreet"
    "DeadTree"
    "Desert"
    "DesertPeak"
    "DesertSands"
    "DesertTree"
    "DesertValley"
    "Disco"
    "Dome"
    "Drool"
    "DynamicFry"
    "EOS-SnowCappedMountain"
    "EOS-Sunset"
    "EOS-ViktorForgacs"
    "EOS-WeYamle"
    "Elementary-OS-Odin"
    "ExternalHimitsuHouse"
    "FedeMarinMountain"
    "Firewatch"
    "Firewatch2"
    "Fluent"
    "FluidifiedST"
    "FocalFossa"
    "Fuji"
    "Globe"
    "GroovyGorilla"
    "Hills"
    "HimitsuHouse"
    "HirsuitHippo"
    "HirsuteHippoBlue"
    "Iphone13Red"
    "KagomeRoom"
    "LakeTheCliff"
    "Lakeside"
    "Libadwaita"
    "LofiAlex"
    "LofiAlexandra"
    "LofiCity"
    "LofiDino"
    "LofiGirl"
    "MagicLake"
    "Material"
    "MaterialMountains"
    "Minimal Mojave"
    "Mojave"
    "MojaveV2"
    "Monterey"
    "MountainsIsland"
    "Ocean"
    "PadarIsland"
    "PaintingStudio"
    "PlasticBeach"
    "Plateau"
    "Riverside"
    "Rock"
    "Rocknegy"
    "Rocksketto"
    "RockyMountain"
    "SolidDesert"
    "SolidForest"
    "SolidIsland"
    "SolidMountain"
    "Solitude"
    "StepbyStep"
    "StevenUniverse"
    "Surface"
    "SurfaceBreeze"
    "Symbolics"
    "TheBeach"
    "TheDesert"
    "TheLake"
    "TokyoStreet"
    "Truchet"
    "UbuntuMinimal"
    "Viragegy"
    "Viragharom"
    "Viragnegy"
    "WaterHill"
    "WhiteLighthouse"
    "Win11Lake"
    "Windows-11-2"
    "Windows-11-3"
    "Windows-11"
    "Wiravketto"
    "ZorinBlur"
    "ZorinMountain"
    "ZorinMountainFog"
    "cyberpunk-01"
  ],
  fetchgit,
}:
stdenv.mkDerivation {
  pname = "linux-dynamic-wallpapers";
  version = "0.1.0";

  src = fetchgit {
    url = "https://github.com/saint-13/Linux_Dynamic_Wallpapers";
    rev = "45128514ae51c6647ab3e427dda2de40c74a40e5";
    hash = "sha256-gmGtu28QfUP4zTfQm1WBAokQaZEoTJ2jL/Qk4BUNrhU=";

    fetchSubmodules = false;
    deepClone = false; # This disables deep clone
  };

  dontBuild = true;

  env = {
    WALLPAPERS = builtins.concatStringsSep "\n" wallpapers;
  };

  installPhase = ''
    # Create the output directory
    mkdir -p $out/share/backgrounds
    mkdir -p $out/share/gnome-background-properties

    # Install only the specified wallpapers
    while IFS= read -r wallpaper; do
      if [ -f "$src/Dynamic_Wallpapers/$wallpaper.xml" ]; then
        cp -r "$src/Dynamic_Wallpapers/$wallpaper/" "$out/share/backgrounds/"
        sed "s@/usr/share/backgrounds/Dynamic_Wallpapers@$out/share/backgrounds@g" "$src/Dynamic_Wallpapers/$wallpaper.xml" > "$out/share/backgrounds/$wallpaper.xml"
        sed "s@/usr/share/backgrounds/Dynamic_Wallpapers@$out/share/backgrounds@g" "$src/xml/$wallpaper.xml" > "$out/share/gnome-background-properties/$wallpaper.xml"
      else
        echo "Warning: Wallpaper $wallpaper not found in source"
      fi
    done <<< "$WALLPAPERS"
  '';

  meta = with lib; {
    description = "Linux dynamic wallpapers";
    homepage = "https://github.com/saint-13/Linux_Dynamic_Wallpapers";
    license = licenses.mit; # Adjust the license accordingly
    platforms = platforms.unix;
  };
}
