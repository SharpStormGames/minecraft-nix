{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.fabric = {
    version = mkOption {
      default = null;
      example = "0.12.5";
      description = ''
        The version of fabric to use.
        You'll most likely want the latest version from https://github.com/FabricMC/fabric-loader/releases
      '';
      type = types.nullOr types.nonEmptyStr;
    };
    hash = mkOption {
      description = ''
        The hash of the fabric version.
        Leave it empty to have nix tell you what to use.
      '';
      type = types.str;
    };
  };

  config.internal = (import ../downloaders/download-module.nix {
    inherit pkgs lib;
    name = "fabric-${config.fabric.version}";
    enabled = config.fabric.version != null;
    hash = config.fabric.hash;
    jsonnetFile = ../jsonnet/download.jsonnet;
    scriptBefore = ''
      curl -L -o orig.json \
        'https://meta.fabricmc.net/v2/versions/loader/${config.minecraft.version}/${config.fabric.version}/profile/json'
    '';
  }).module;
}
