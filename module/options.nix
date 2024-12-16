{ lib, ... }: let inherit (lib) mkOption types; in {
  options = {
    gamedir = mkOption {
      description = ''
        The directory where worlds, mods and other files are stored.
        If it's not an absolute path, it's relative to the working directory
        where you run minecraft.
        Can be overwritten with the "MINECRAFT_GAMEDIR" environment variable.
      '';
      example = "./gamedir";
      type = types.nonEmptyStr;
    };

    extraGamedirFiles = mkOption {
      description = "Extra files to symlink into the game directory.";
      default = [ ];
      type = types.listOf (types.submodule {
        options = {
          path = mkOption {
            description = "Where to link the file, relative to the game directory.";
            example = "config/something.cfg";
            type = types.nonEmptyStr;
          };
          source = mkOption {
            description = "Path to the file to be linked.";
            type = types.path;
          };
        };
      });
    };

    cleanFiles = mkOption {
      description = ''
        Files and directories relative to the game directory to delete on every
        startup. Defaults to the "mods" folder.
      '';
      example = ''
        <pre><code>
        [ "config" "mods" "resourcepacks" "options.txt" ]
        </code></pre>
      '';
      default = [ "mods" ];
      type = types.listOf types.nonEmptyStr;
    };

    mods.manual = mkOption {
      example = ''
        <pre><code>
        map pkgs.fetchurl [
          # Extended Hotbar
          {
            url = "https://github.com/DenWav/ExtendedHotbar/releases/download/1.2.0/mod-extendedhotbar-1.2.0-mc1.12.2.litemod";
            hash = "sha256-CyB7jypxXq41wAfb/t1RCsxaS8uZZjAl/h531osq0Fc=";
          }
        ]
        </code></pre>
      '';
      default = [ ];
      type = types.listOf types.path;
      description = ''
        A list of .jar files to use as mods.
      '';
    };

    runners.client = mkOption {
      type = types.package;
      internal = true;
    };

    postInstall = mkOption {
      type = types.str;
      internal = true;
      default = "";
    };

    jre = mkOption {
      type = types.package;
      internal = true;
    };
  };
}