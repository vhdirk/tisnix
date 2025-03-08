{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.zsh.zsh4humans;
  dotDir = config.programs.zsh.dotDir;

  relToDotDir = file: (optionalString (dotDir != null) (dotDir + "/")) + file;
  zdotdir = "$HOME/" + lib.escapeShellArg dotDir;

  pluginsDir =
    if dotDir != null
    then relToDotDir "plugins"
    else ".zsh/plugins";

  pluginModule = types.submodule ({config, ...}: {
    options = {
      src = mkOption {
        type = types.path;
        description = ''
          Path to the plugin folder.

          Will be added to {env}`fpath` and {env}`PATH`.
        '';
      };

      name = mkOption {
        type = types.str;
        description = ''
          The name of the plugin.

          Don't forget to add {option}`file`
          if the script name does not follow convention.
        '';
      };

      load = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "The plugin script to source.";
      };

      trigger = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "The plugin script to source.";
      };

      fpath = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The plugin script to source.";
      };

      managed = mkOption {
        type = types.bool;
        default = true;
        description = "If plugin is managed by nix";
      };
    };
  });

  cacheDir = "${config.home.homeDirectory}/.cache/zsh";
in {
  options.programs.zsh.zsh4humans = {
    enable = mkEnableOption "Zsh for Humans";

    plugins = mkOption {
      default = [];
      type = types.listOf pluginModule;
      description = "List of z4h plugins.";
    };

    # z4hHome = mkOption {
    #   type = types.path;
    #   default = "${config.home.homeDirectory}/.zplug";
    #   defaultText = "~/.zplug";
    #   apply = toString;
    #   description = "Path to zplug home directory.";
    # };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [pkgs.zsh4humans];
    }

    # ({
    #   programs.zsh.initExtraBeforeCompInit = ''
    #     .cache_z4h() {
    #       local SRC_BASE_PATH="$1"
    #       local CACHE_BASE_PATH="$2"
    #       local SUB="$3"

    #       local SRC_PATH=$(realpath "''${SRC_BASE_PATH}/''${SUB}")
    #       local CACHE_PATH="''${CACHE_BASE_PATH}/''${SUB}"
    #       local SRC_PATH_FILE="''${CACHE_PATH}/.srcpath"

    #       if [[ ! -f "''${SRC_PATH_FILE}" || "$(cat "''${SRC_PATH_FILE}")" != "''${SRC_PATH}" ]]; then
    #         echo "Caching $SUB"
    #         mkdir -p "''${CACHE_PATH}"
    #         chmod -R u+rw "''${CACHE_PATH}"
    #         cp -rT "''${SRC_PATH}" "''${CACHE_PATH}"
    #         chmod -R u+rw "''${CACHE_PATH}"
    #         echo "''${SRC_PATH}" > "''${SRC_PATH_FILE}"
    #       fi
    #     }

    #     .cache_z4h_bin() {
    #       .cache_z4h "${pkgs.zsh4humans}/share" "${cacheDir}" z4h
    #     }

    #     .cache_z4h_plugin() {
    #       local PLUGIN="$1"
    #       .cache_z4h "${config.home.homeDirectory}/${pluginsDir}" "${cacheDir}/plugins" "''${PLUGIN}"
    #     }

    #     .cache_z4h_bin
    #     source "${cacheDir}/z4h/z4h.zsh"

    #     ${optionalString (cfg.plugins != [ ]) ''
    #       ${concatStrings (map (plugin:
    #       ''
    #         ${
    #           if lib.strings.hasPrefix "/" plugin.src then
    #             ''.cache_z4h_plugin "${plugin.name}"; PLUGIN="${cacheDir}/plugins/${plugin.name}"''
    #           else
    #             ''PLUGIN="${plugin.src}"''
    #         }
    #         ${
    #           optionalString (plugin.load != [ ]) ''
    #             z4h load "$PLUGIN" ${concatStrings (map (f: " ${f}") plugin.load)}
    #           ''
    #         }
    #         ${
    #           optionalString (plugin.trigger != [ ]) ''
    #             z4h trigger ${concatStrings (map (f: " ${f}") plugin.trigger)} "$PLUGIN"
    #           ''
    #         }
    #         ${
    #           optionalString (plugin.fpath !=null) ''
    #             z4h fpath "$PLUGIN" ${plugin.fpath}
    #           ''
    #         }
    #       '') cfg.plugins)}
    #     ''}
    #   '';
    # })

    # source_dir="source_directory"
    # copy_dir="copy_directory"
    # hash_file=".dirhash"

    # if [[ -f "$source_dir/$hash_file" ]]; then
    #     # Read the hash from the source and compute the hash for the copy
    #     source_hash=$(<"$source_dir/$hash_file")
    #     copy_hash=$(find "$copy_dir" -type f -name "*.zsh" -exec sha256sum {} + | sha256sum | awk '{print $1}')

    #     # Compare the hashes
    #     if [[ "$source_hash" != "$copy_hash" ]]; then
    #         echo "Directories differ. Recopying..."
    #         rm -rf "$copy_dir"
    #         cp -r "$source_dir" "$copy_dir"
    #     else
    #         echo "Directories are in sync."
    #     fi
    # else
    #     echo "Hash file missing in source directory. Please regenerate it."
    # fi

    # export ZPLUG_HOME=${cfg.zsh4humansHome}

    # source ${pkgs.zplug}/share/z4h/z4h.zsh

    # if ! zplug check; then
    #   zplug install
    # fi

    # zplug load

    (mkIf (cfg.plugins != []) {
      # Many plugins require compinit to be called
      # but allow the user to opt out.
      home.file = foldl' (a: b: a // b) {} (map (plugin: {
          "${config.home.homeDirectory}/${pluginsDir}/${plugin.name}".source =
            plugin.src;
        })
        cfg.plugins);

      # home.activation.zsh4humansPluginsTimestamp = ''
      #   date +%s > ${config.home.homeDirectory}/${pluginsDir}/.timestamp
      # '';
    })
  ]);
}
