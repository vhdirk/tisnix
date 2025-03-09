{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.gnome-keybindings;

  customKeybindingType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Name";
      };

      binding = mkOption {
        type = types.str;
        description = "Name";
      };

      command = mkOption {
        type = types.str;
        description = "Name";
      };
    };
  };

  keybindingsConfigType = types.submodule {options = {};};

  keybindingKey = {custom = "custom-keybindings";};
  keybindingPath = {
    mutter = "org/gnome/mutter/keybindings";
    media = "org/gnome/settings-daemon/plugins/media-keys";
    windowManager = "org/gnome/desktop/wm/keybindings";
  };

  mkCustomKeyBindingsPath = name: "${keybindingPath.media}/${keybindingKey.custom}/${name}";

  customKeybindingsConf = bindings:
    lib.listToAttrs (lib.mapAttrsToList (name: binding: {
        name = "${mkCustomKeyBindingsPath name}";
        value = binding;
      })
      bindings);

  customKeybindingPaths = bindings:
    map (name: "/${(mkCustomKeyBindingsPath name)}/")
    (builtins.attrNames bindings);

  mkGnomeKeybindings = {
    media ? {},
    windowManager ? {},
    mutter ? {},
    custom ? {},
  }:
    {
      "${keybindingPath.windowManager}" = windowManager;
      "${keybindingPath.mutter}" = mutter;
      "${keybindingPath.media}" =
        media
        // {
          "${keybindingKey.custom}" = customKeybindingPaths custom;
        };
    }
    // (customKeybindingsConf custom);
in {
  options.custom.programs.gnome-keybindings = {
    enable = mkEnableOption "GNOME Keybindings management";

    media = mkOption {
      type = with types; attrsOf (listOf str);
      default = {};
      description = "Media keybindings";
    };

    windowManager = mkOption {
      type = with types; attrsOf (listOf str);
      default = {};
      description = "window manager keybindings";
    };

    mutter = mkOption {
      type = with types; attrsOf (listOf str);
      default = {};
      description = "mutter keybindings";
    };

    custom = mkOption {
      type = with types; attrsOf customKeybindingType;
      default = {};
      description = "Custom keybindings";
    };
  };

  config = mkIf cfg.enable {
    dconf.settings = mkGnomeKeybindings cfg;
  };
}
