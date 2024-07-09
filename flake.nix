{
  description = "Command line Minecraft launcher managed by nix";

  inputs = {
   nixpkgs = { url = "github:NixOS/nixpkgs"; };
   flake-utils = { url = "github:numtide/flake-utils"; };
  };
  outputs = { self, nixpkgs, flake-utils }:
   with flake-utils.lib;
   with nixpkgs.lib;
   with builtins;
   let
    importJSONFiles = dir:
     listToAttrs (map (fp: {
      name = removeSuffix ".json" (baseNameOf fp);
      value = importJSON fp;
    }) (filesystem.listFilesRecursive dir));
    in eachDefaultSystem (system:
     let
      inherit (pkgs) lib;
      pkgs = nixpkgs.legacyPackages.${system};
      OS = with pkgs.stdenv;
       if isLinux then
        "linux"
       else if isDarwin then
        "osx"
       else
        builtins.throw "Unsupported system ${system}";
      py = pkgs.python3.withPackages (p: [ p.requests ]);
      in {
       legacyPackages = lib.makeOverridable (import ./build/packages.nix) {
        inherit pkgs lib OS;
        authClientID = "adf6c624-b9ba-472e-9469-e54cc8f98e87";
       };
       apps.update = mkApp {
        drv = let
         snippet = dir: ''
          pushd ./meta/${dir}
          ${py}/bin/python update.py
          popd
        '';
        in pkgs.writeShellScriptBin "update" ''
         set -e
         ${snippet "vanilla"}
         ${snippet "fabric"}
         ${snippet "quilt"}
        '';
       };
      }) // {
       manifests = importJSON ./meta/vanilla/manifests.json;
       versions = importJSONFiles ./meta/vanilla/versions;
       assets = importJSONFiles ./meta/vanilla/asset_indices;
       fabric.profiles = importJSON ./meta/fabric/profiles.json;
       fabric.libraries = importJSON ./meta/fabric/libraries.json;
       fabric.loaders = importJSON ./meta/fabric/loaders.json;
       quilt.profiles = importJSON ./meta/quilt/profiles.json;
       quilt.libraries = importJSON ./meta/quilt/libraries.json;
       quilt.loaders = importJSON ./meta/quilt/loaders.json;
      };
}
