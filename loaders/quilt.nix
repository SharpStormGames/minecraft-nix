{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.quilt = {
    version = mkOption {
      default = null;
      example = "0.12.5";
      description = ''
        The version of quilt to use.
        You'll most likely want the latest version from https://github.com/quiltmc/quilt-loader/releases
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

  config.internal = (import ../assets/downloaders/download-module.nix {
    inherit pkgs lib;
    name = "quilt-${config.quilt.version}";
    enabled = config.quilt.version != null;
    hash = config.quilt.hash;
    jsonnetFile = ../assets/jsonnet/download.jsonnet;
    scriptBefore = ''
      curl -L -o orig.json \
        'https://meta.quiltmc.org/v3/versions/loader/${config.minecraft.version}/${config.quilt.version}/profile/json'
    '';
  }).module;
}
