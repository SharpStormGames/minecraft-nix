{ config, pkgs, lib, ... }:
{
  imports = [ ./options.nix ];
  
  config = {
    jre = { "8" = pkgs.jdk8; "16" = pkgs.jdk8; "17" = pkgs.jdk17; "21" = pkgs.jdk; }.${toString config.internal.javaVersion};

    extraGamedirFiles = let getName = x:
      if builtins.isPath x
      then builtins.baseNameOf "${x}"
      else x.name;
      in map (m: { path = "mods/${getName m}"; source = m; })
        config.mods.manual;

    runners.client = let

      pythonWithRequests = pkgs.python3.withPackages (ps: [ ps.requests ]);

      nativeLibsDir = pkgs.symlinkJoin {
        name = "minecraft-natives";
        paths = config.downloaded.natives ++ [ "${pkgs.libpulseaudio}/lib" "${pkgs.xorg.libXxf86vm}/lib" "${pkgs.libGL}/lib" "${pkgs.flite.lib}/lib" ];
      };

      jarsDir = pkgs.symlinkJoin {
        name = "minecraft-libraries";
        paths = config.downloaded.jars;
      };

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

      runner = pkgs.writeShellScript "minecraft-runner" ''
        set -o errexit
        set -o pipefail
        script_dir=$(dirname "$(realpath "$0")")
        PATH='${lib.makeBinPath (with pkgs; [ coreutils rsync jq nushell zenity wl-clipboard xclip])}:$PATH'
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
        ${lib.optionalString (config.cleanFiles != []) '' rm -rfv ${lib.escapeShellArgs config.cleanFiles} ''}
        ${lib.optionalString (extraGamedir != null) '' rsync -rL --ignore-existing --chmod=755 --info=skip2,name $out/gamedir/ "$game_directory" ''}
        cp -ru ${config.downloaded.assets} $game_directory/assets
        chmod -R 777 $game_directory/assets/
        assets_root="$game_directory/assets"
        assets_index_name='${config.internal.assets.id}'
        ulimit -n 4096 || echo "warning: couldn't increase file descriptor limit, continuing" 1>&2
        cd $out/bin && ${pythonWithRequests}/bin/python auth.py
        cd $game_directory
        uuid=$(jq -r '.uuid' ~/.cache/mc-nix-creds.json)
        username=$(jq -r '.username' ~/.cache/mc-nix-creds.json)
        accessToken=$(jq -r '.accessToken' ~/.cache/mc-nix-creds.json)
        exec env \
          -u PATH \
          LD_LIBRARY_PATH="$jnatemp_directory:$natives_directory" \
          ${config.jre}/bin/java \
          -Djna.tmpdir=$jnatemp_directory \
          -Djava.library.path="$jnatemp_directory:$natives_directory" \
          -Dloader.ignore_unsupported_mods=true \
          -classpath "$classpath" \
          '${config.internal.mainClass}' \
          --assetIndex "${config.internal.assets.id}" \
          --assetsDir "$assets_root" \
          --uuid "$uuid" \
          --username "$username" \
          --accessToken "$accessToken" \
          --userType "msa" \
          --version "${config.minecraft.version}" \
      '';
    in
    pkgs.stdenvNoCC.mkDerivation {
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
        ${lib.optionalString (extraGamedir != null) "ln -s ${extraGamedir} $out/gamedir"}
        echo creating runner script
        mkdir -p $out/bin
        sed "s|%OUT%|$out|" ${runner} > $out/bin/minecraft
        chmod +x $out/bin/minecraft
        cp ${./auth.py} $out/bin/auth.py
        cp ${./auth.nu} $out/bin/auth.nu
        chmod +x $out/bin/auth.nu
        ${config.postInstall}
      '';
      passthru = { inherit config; };
    };
  };
}