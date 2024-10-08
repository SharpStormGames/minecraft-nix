{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
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

  config.jre = {
    "8" = pkgs.jdk8; # < 1.16.5
    "16" = pkgs.jdk8; # 1.16.5
    "17" = pkgs.jdk17; # 1.17 - 1.19
    "21" = pkgs.jdk; # 1.20+
  }.${toString config.internal.javaVersion};

  config.extraGamedirFiles =
    let getName = x:
      if builtins.isPath x
      then builtins.baseNameOf "${x}"
      else x.name;
    in
    map
      (m: { path = "mods/${getName m}"; source = m; })
      config.mods.manual;

  config.runners.client =
    let
      nativeLibsDir = pkgs.symlinkJoin {
        name = "minecraft-natives";
        paths =
          config.downloaded.natives
          ++ [
            "${pkgs.libpulseaudio}/lib"
            "${pkgs.xorg.libXxf86vm}/lib"
            "${pkgs.libGL}/lib"
            "${pkgs.flite.lib}/lib"
          ];
      };

      jarsDir = pkgs.symlinkJoin {
        name = "minecraft-libraries";
        paths = config.downloaded.jars;
      };

      # jarsDir =
      #   let
      #     copyJoin =
      #       { name, paths }:
      #       let
      #         args = {
      #           inherit paths;
      #           passAsFile = [ "paths" ];
      #         };
      #       in
      #       pkgs.runCommand name args ''
      #         mkdir -p $out
      #         for i in $(cat $pathsPath); do
      #           cp -rnL --no-preserve=all $i/* $out
      #         done
      #       '';
      #   in
      #   copyJoin {
      #     name = "minecraft-libraries";
      #     paths = config.downloaded.jars;
      #   };

      classpath = lib.concatMapStringsSep ":"
        (x: "$library_directory/" + x.destPath)
        (lib.filter
          (x: x.type == "jar" && x.installerOnly == false)
          config.internal.libraries);

      extraGamedir =
        if config.extraGamedirFiles == [ ]
        then null
        else
          let scripts = map
            ({ path, source }: ''
              mkdir -p "$(dirname "$out"/${lib.escapeShellArg path})"
              ln -s ${lib.escapeShellArg source} "$out"/${lib.escapeShellArg path}
            '')
            config.extraGamedirFiles;
          in
          pkgs.runCommand "symlink-gamedir-files" { }
            (lib.concatStringsSep "\n" scripts);

      argsToString = lib.concatMapStringsSep " " (x: ''"${x}"'');

      runner = pkgs.writeShellScript "minecraft-runner" ''
        set -o errexit
        set -o pipefail
        PATH='${lib.makeBinPath (with pkgs; [ coreutils rsync ])}'
        out='%OUT%'
        version_name='${config.minecraft.version}'
        game_directory="''${MINECRAFT_GAMEDIR:-${config.gamedir}}"
        game_directory="$(realpath "$game_directory")"
        natives_directory="$out/natives"
        library_directory="$out/libraries"
        jnatemp_directory="/tmp/mc-jnatemp/${config.minecraft.version}/"
        classpath_separator=':'
        classpath="${classpath}"
        mkdir -p "$jnatemp_directory"
        mkdir -p "$game_directory"
        cd "$game_directory"
        ${lib.optionalString (config.cleanFiles != [])
        ''
          rm -rfv ${lib.escapeShellArgs config.cleanFiles}
        ''}
        ${lib.optionalString (extraGamedir != null)
        ''
          echo "copying files to game directory ($game_directory)"
          rsync -rL --ignore-existing --chmod=755 --info=skip2,name $out/gamedir/ "$game_directory"
        ''}
        assets_root="$out/assets"
        assets_index_name='${config.internal.assets.id}'

        # larger modpacks could need more open file descriptors
        ulimit -n 4096 || echo "warning: couldn't increase file descriptor limit, continuing" 1>&2
        

        exec env \
          -u PATH \
          LD_LIBRARY_PATH="$jnatemp_directory:$natives_directory:$LD_LIBRARY_PATH" \
          ${config.jre}/bin/java \
          ${argsToString config.internal.jvmArgs} \
          -Djna.tmpdir=$jnatemp_directory \
          -Djava.library.path="$jnatemp_directory:$natives_directory" \
          -classpath "$classpath" \
          '${config.internal.mainClass}' \
          --assetIndex "${config.internal.assets.id}" \
          --assetsDir "$assets_root" \
          --uuid "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" \
          --username "aaaaaaaaa" \
          --accessToken "" \
          --userType "Local" \
          --version "${config.minecraft.version}" \
      '';
    in
    pkgs.stdenvNoCC.mkDerivation
      {
        pname = "minecraft";
        version = config.minecraft.version;

        dontUnpack = true;
        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          echo setting up environment
          mkdir -p $out
          ln -s ${nativeLibsDir} $out/natives
          ln -s ${jarsDir} $out/libraries
          ln -s ${config.downloaded.assets} $out/assets
          ${lib.optionalString
          (extraGamedir != null)
          "ln -s ${extraGamedir} $out/gamedir"}
          echo creating runner script
          mkdir -p $out/bin
          sed "s|%OUT%|$out|" ${runner} > $out/bin/minecraft
          chmod +x $out/bin/minecraft

          ${config.postInstall}
        '';

        passthru = {
          inherit config;
        };
      };
}
