{ config, lib, pkgs, ... }:
let
 inherit (lib) mkIf versionAtLeast;
 inherit (lib.strings)
  makeLibraryPath concatStringsSep concatMapStringsSep
  optionalString;
 inherit (pkgs) writeShellScriptBin jq linkFarmFromDrvs xorg;
 inherit (pkgs.writers) writePython3;
in {
 imports = [
  ./launch-script.nix
  ./java.nix
  ./files.nix
  ./version.nix
  ./options.nix
 ];

 config = {
  files."assets/indexes".source = "${config.assets.directory}/indexes";
  files."assets/objects".source = "${config.assets.directory}/objects";
  files."resourcepacks" = {
   source = linkFarmFromDrvs "resourcepacks" config.resourcePacks;
   recursive = !config.declarative;
  };
  files."shaderpacks" = {
   source = linkFarmFromDrvs "shaderpacks" config.shaderPacks;
   recursive = !config.declarative;
  };

  launchScript = {
   preparation = {
    parseRunnerArgs = {
     deps = [ "parseArgs" ];
     text = ''
      XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
      PROFILE="$XDG_DATA_HOME/minecraft-nix/profile.json"
      mcargs=()
       function parse_runner_args() {
        while [[ "$#" -gt 0 ]];do
        if [[ "$1" == "--launch-profile" ]];then
         shift 1
        if [[ "$#" -gt 0 ]];then
         PROFILE="$1"
        fi
        else
         mcargs+=("$1")
        fi
         shift 1
        done
       }
       parse_runner_args "''${runner_args[@]}"
     '';
    };
    auth = let
     ensureAuth = writePython3 "ensureAuth" {
      libraries = with pkgs.python3Packages; [
       requests
       pyjwt
       colorama
       cryptography
      ];
      flakeIgnore = [ "E501" "E402" "W391" ];
     } ''
      ${builtins.replaceStrings [ "@CLIENT_ID@" ] [ config.authClientID ]
       (builtins.readFile ../auth/msa.py)}
      ${builtins.readFile ../auth/login.py}
     '';
    in {
     deps = [ "parseRunnerArgs" ];
     text = let json = "${jq}/bin/jq --raw-output";
    in ''
     ${ensureAuth} --profile "$PROFILE"
      UUID=$(${json} '.["id"]' "$PROFILE")
      USER_NAME=$(${json} '.["name"]' "$PROFILE")
      ACCESS_TOKEN=$(${json} '.["mc_token"]["__value"]' "$PROFILE")
    '';
    };
   };
   path = mkIf (!(versionAtLeast config.version "1.13")) [ xorg.xrandr ];
   gameExecution = let libPath = makeLibraryPath config.libraries.preload;
   in ''
    export LD_LIBRARY_PATH="${libPath}''${LD_LIBRARY_PATH:+':'}''${LD_LIBRARY_PATH:-}"
    exec "${config.java}" \
     -Djava.library.path='${
      concatMapStringsSep ":" (native: "${native}/lib")
      config.libraries.native
     }' \
    -cp '${concatStringsSep ":" config.libraries.java}' \
     ${
      optionalString (config.mods != [ ])
      "-Dfabric.addMods='${concatStringsSep ":" config.mods}'"
     } \
     ${config.mainClass} \
      --version "${config.version}" \
      --assetIndex "${config.assets.index}" \
      --uuid "$UUID" \
      --username "$USER_NAME" \
      --accessToken "$ACCESS_TOKEN" \
      --userType "msa" \
      "''${mcargs[@]}"
   '';
  };
  launcher = writeShellScriptBin "minecraft-${config.version}-${config.mainClass}" config.launchScript.finalText;
 };
}
