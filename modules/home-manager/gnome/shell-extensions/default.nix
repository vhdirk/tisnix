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
        type = types.nullOr types.package;
        default = null;
        description = "The extension package";
        example = "pkgs.gnomeExtensions.dash-to-dock";
      };

      uuid = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The uuid of the extension";
        example = "GPaste@gnome-shell-extensions.gnome.org";
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

  # Parse a single extension configuration entry
  parseExtensionConfig = ext: let
    # Determine the package
    pkg =
      if lib.isString ext then null
      else if (builtins.hasAttr "pkg" ext) && (ext.pkg != null) then ext.pkg
      else if ext != null
      then ext
      else null;

    # Determine the uuid
    uuid =
      if lib.isString ext then ext
      else if (builtins.hasAttr "uuid" ext) && (ext.uuid != null)
      then ext.uuid
      else if pkg != null
      then pkg.extensionUuid
      else if ext != null
      then ext
      else null;

    # Determine enable status
    enable =
      if lib.isString ext
      then true
      else if ext ? enable
      then ext.enable
      else true;

    # Determine settings key
    settingsKey =
      if lib.isString ext then uuid
      else if (builtins.hasAttr "settingsKey" ext) && (ext.settingsKey != "")
      then ext.settingsKey
      else uuid;

    # Determine settings
    settings =
      if lib.isString ext
      then {}
      else if ext ? settings
      then ext.settings
      else {};
  in
    # Validate that either pkg or uuid is present
    if (pkg == null) && (uuid == null)
    then throw "Extension configuration must have either a package or a uuid"
    else {
      inherit pkg uuid enable settingsKey settings;
    };

  extensionList = map parseExtensionConfig cfg.extensions;

  # Generate dconf settings for an extension
  mkDConfSettings = ext: let
    settingsPath = "org/gnome/shell/extensions/${ext.settingsKey}";
    nestedAttrs = builtins.all (value: builtins.isAttrs value) (builtins.attrValues ext.settings);
  in
    if nestedAttrs
    then
      mapAttrs'
      (
        subPath: subSettings:
          nameValuePair "${settingsPath}${subPath}" subSettings
      )
      ext.settings
    else {
      ${settingsPath} = ext.settings;
    };
in {
  options.custom.programs.gnome-shell-extensions = {
    enable = mkEnableOption "GNOME Shell extensions management";

    extensions = mkOption {
      type = types.listOf (types.oneOf [types.package types.str extensionConfigType]);
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
          "extension@gnome.org"
        ]
      '';
    };
  };

  config = mkIf cfg.enable {
    # Ensure GNOME Shell is installed and install extensions
    home.packages = [pkgs.gnome-shell] ++ map (e: e.pkg) (filter (e: e.enable && e.pkg != null) extensionList);

    # Install and configure extensions
    dconf.settings = let
      # Fill out dconf settings
      extensionSettings = filter (set: attrNames set != []) (map mkDConfSettings extensionList);
    in
      mkMerge (
        # Enable/disable extensions
        [
          {
            "org/gnome/shell" = {
              disable-user-extensions = false; # enables user extensions
              enabled-extensions = map (e: builtins.toString e.uuid) (filter (e: e.enable) extensionList);
              disabled-extensions = map (e: builtins.toString e.uuid) (filter (e: !e.enable) extensionList);
            };
          }
        ]
        ++
        # Extension specific settings
        extensionSettings
      );
  };
}
