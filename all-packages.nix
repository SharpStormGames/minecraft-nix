{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, authClientID, OS ? "linux" }:
with lib;
let
 extendedLib = lib.extend (import ./common.nix { inherit pkgs lib; });
 client = import ./builder/client.nix {
  lib = extendedLib;
  inherit pkgs authClientID OS;
 };
 manifests = importJSON ./metadata/vanilla/manifests.json;
 convertVersion = v: "v" + replaceStrings [ "." " " ] [ "_" "_" ] v;
in mapAttrs' (gameVersion: assets: {
 name = convertVersion gameVersion;
 value = let
  clients = client.build gameVersion assets;
  notSupported = pkgs.writeShellScriptBin "notSupported" ''
   Fabric loader does not support game version "${gameVersion}".
  '';
 in {
  fabric.client = clients.fabric or notSupported;
  vanilla.client = clients.vanilla;
 };
}) manifests
