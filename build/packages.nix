{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, authClientID }:
with lib;
let
 extendedLib = lib.extend (import ./common.nix { inherit pkgs lib; });
 client = import ./client.nix {
  lib = extendedLib;
  inherit pkgs authClientID;
 };
 manifests = importJSON ../meta/vanilla/manifests.json;
 convertVersion = v: "v" + replaceStrings [ "." " " ] [ "_" "_" ] v;
in mapAttrs' (gameVersion: assets: {
 name = convertVersion gameVersion;
 value = let
  clients = client.build gameVersion assets;
  notSupported = pkgs.writeShellScriptBin "notSupported" ''
   Fabric/Quilt loader does not support game version "${gameVersion}".
  '';
 in {
  fabric = clients.fabric or notSupported;
  quilt = clients.quilt or notSupported;
  vanilla = clients.vanilla;
 };
}) manifests
