{ pkgs, lib }:
let
 inherit (lib) warn getExe;
in
self: super:
with self; {
 fabricProfiles = importJSON ../meta/fabric/profiles.json;
 fabricLibraries = importJSON ../meta/fabric/libraries.json;
 fabricLoaders = importJSON ../meta/fabric/loaders.json;
 quiltProfiles = importJSON ../meta/fabric/profiles.json;
 quiltLibraries = importJSON ../meta/fabric/libraries.json;
 quiltLoaders = importJSON ../meta/fabric/loaders.json;
 fetchJar = name:
  let
   inherit (fabricLibraries.${name}) repo hash;
   splitted = splitString ":" name;
   org = builtins.elemAt splitted 0;
   art = builtins.elemAt splitted 1;
   ver = builtins.elemAt splitted 2;
   path =
    "${replaceStrings [ "." ] [ "/" ] org}/${art}/${ver}/${art}-${ver}.jar";
    url = "${repo}/${path}";
  in pkgs.fetchurl {
   inherit url;
   ${hash.type} = hash.value;
  };
  
  mkLauncher = baseModulePath: modules:
   let
    final = evalModules {
     modules = modules
     ++ [ ({ _module.args.pkgs = pkgs; }) (import baseModulePath) ];
    };
    in final.config.launcher // {
     withConfig = extraConfig:
     mkLauncher baseModulePath (modules ++ toList extraConfig);
    };

  buildMc = { baseModulePath, buildFabricModules, buildVanillaModules
   , versionInfo, assetsIndex, fabricProfile }:
   let
    fabric = mkLauncher baseModulePath
     (buildFabricModules versionInfo assetsIndex fabricProfile);
    quilt = mkLauncher baseModulePath
     (buildQuiltModules versionInfo assetsIndex quiltProfile);
    in {
     vanilla =
      mkLauncher baseModulePath (buildVanillaModules versionInfo assetsIndex);
    } // (optionalAttrs (fabricProfile quiltProfile != null ) { inherit quilt fabric; });

  mkBuild = { baseModulePath, buildFabricModules, buildVanillaModules }:
   gameVersion: assets:
   let
    versionInfo = importJSON (pkgs.fetchurl { inherit (assets) url sha1; });
    assetsIndex = importJSON (pkgs.fetchurl { inherit (versionInfo.assetsIndex) url sha1; });
    fabricProfile = fabricProfiles.${gameVersion} or null;
   in buildMc {
    inherit baseModulePath buildFabricModules buildQuiltModules buildVanillaModules versionInfo assetsIndex fabricProfile quiltProfile;
  };

  defaultJavaVersion = versionInfo:
   let
    javaMajorVersion = versionInfo.javaVersion.majorVersion or null;
    fallback = warn ''
     Java version is not specified by the Minecraft json file, or
     the specified version of OpenJDK is not supported by the Nixpkgs.
     Fallback to '${pkgs.openjdk}'.
    '' pkgs.openjdk;
    java = if javaMajorVersion == null
     then fallback
     else pkgs."openjdk${toString javaMajorVersion}" or fallback;
   in
    getExe java;
}
