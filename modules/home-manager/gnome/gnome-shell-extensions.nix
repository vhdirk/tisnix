{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.gnome-shell-extensions;

  extensionConfigType = types.submodule {
    options = {
      pkg = mkOption {
        type = types.package;
        description = "The extension package";
        example = "pkgs.gnomeExtensions.dash-to-dock";
      };

      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the extension should be enabled";
      };

      settingsKey = mkOption {
        type = types.str;
        default = "";
        description = "Name of key";
      };

      settings = mkOption {
        type = with types; attrsOf (either hm.types.gvariant (attrsOf hm.types.gvariant));
        default = {};
        description = "DConf settings for the extension";
        example = literalExpression ''
          {
            "dock-position" = "BOTTOM";
            "extend-height" = true;
          }
        '';
      };
    };
  };

  hasExactFields = attrs:
    builtins.length (builtins.attrNames attrs)
    >= 3
    && builtins.hasAttr "pkg" attrs
    && builtins.hasAttr "enable" attrs
    && builtins.hasAttr "settings" attrs;

  extensionList =
    map (
      ext:
        if hasExactFields ext
        then ext
        else {
          pkg = ext;
          enable = true;
          settingsKey = ext.extensionPortalSlug;
          settings = {};
        }
    )
    cfg.extensions;

  # Generate dconf settings for an extension
  mkDConfSettings = extension: let
    settingsPath = "org/gnome/shell/extensions/${
      if extension.settingsKey == ""
      then extension.pkg.extensionPortalSlug
      else extension.settingsKey
    }";
    nestedAttrs = builtins.all (value: builtins.isAttrs value) (builtins.attrValues extension.settings);
  in
    if nestedAttrs
    then
      mapAttrs'
      (
        subPath: subSettings:
          nameValuePair "${settingsPath}${subPath}" subSettings
      )
      extension.settings
    else {
      ${settingsPath} = extension.settings;
    };
in {
  options.custom.programs.gnome-shell-extensions = {
    enable = mkEnableOption "GNOME Shell extensions management";

    extensions = mkOption {
      type = types.listOf (types.either types.package extensionConfigType);
      default = [];
      description = "List of GNOME Shell extensions to install and configure";
      example = literalExpression ''
        [
          pkgs.gnomeExtensions.appindicators
          {
            pkg = pkgs.gnomeExtensions.dash-to-dock;
            enable = true;
            settings = {
              "dock-position" = "BOTTOM";
              "extend-height" = true;
            };
          }
        ]
      '';
    };
  };

  config = mkIf cfg.enable {
    # Ensure GNOME Shell is installed and install extensions
    home.packages = [pkgs.gnome-shell] ++ map (e: e.pkg) (filter (e: e.enable) extensionList);

    # Install and configure extensions
    dconf.settings = let
      # Fill out dconf settings
      extensionSettings = filter (set: attrNames set != []) (map (ext: mkDConfSettings ext) extensionList);
    in
      mkMerge (
        # Enable/disable extensions
        [
          {
            "org/gnome/shell" = {
              disable-user-extensions = false; # enables user extensions
              enabled-extensions = map (e: e.pkg.extensionUuid) (filter (e: e.enable) extensionList);
              disabled-extensions = map (e: e.pkg.extensionUuid) (filter (e: !e.enable) extensionList);
            };
          }
        ]
        ++
        # Extension specific settings
        extensionSettings
      );
  };
}
