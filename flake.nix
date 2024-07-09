{
  description = "Command line Minecraft launcher managed by nix";

  inputs = {
   nixpkgs = { url = "github:NixOS/nixpkgs"; };
   flake-utils = { url = "github:numtide/flake-utils"; };
   metadata = {
    url = "github:Ninlives/minecraft.json";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
   };
  };
  outputs = { self, nixpkgs, flake-utils, metadata }:
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
       legacyPackages = lib.makeOverridable (import ./all-packages.nix) {
        inherit pkgs lib metadata OS;
        authClientID = "adf6c624-b9ba-472e-9469-e54cc8f98e87";
       };
       apps.update = mkApp {
        drv = let
         snippet = dir: ''
          pushd ./metadata/${dir}
          ${py}/bin/python update.py
          popd
        '';
        in pkgs.writeShellScriptBin "update" ''
         set -e
         ${snippet "vanilla"}
         ${snippet "fabric"}
        '';
       };
      }) // {
       manifests = importJSON ./metadata/vanilla/manifests.json;
       versions = importJSONFiles ./metadata/vanilla/versions;
       assets = importJSONFiles ./metadata/vanilla/asset_indices;
       fabric.profiles = importJSON ./metadata/fabric/profiles.json;
       fabric.libraries = importJSON ./metadata/fabric/libraries.json;
       fabric.loaders = importJSON ./metadata/fabric/loaders.json;
      };
}
