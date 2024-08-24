{ baseModules }:
{ pkgs, config, lib, ... }:
let
  cfg = config.programs.minecraft;
  inherit (lib) mkOption mkDefault mkEnableOption mkOptionType mergeOneOption types;
in
{
  options.programs.minecraft = {
    enable = mkEnableOption "minecraft";
    basePath = mkOption {
      type = types.nonEmptyStr;
      default = ".minecraft";
      example = "games/minecraft";
      description = "Path to store versions of minecraft in. Relative to the home directory.";
    };
    shared = mkOption {
      type = mkOptionType {
        name = "shared-module";
        inherit (types.submodule { }) check;
        merge = lib.options.mergeOneOption;
      };
      default = { };
      description = "The config to be shared between all versions.";
    };
    versions = mkOption {
      default = { };
      description = "Versions of minecraft to install.";
      type = types.attrsOf (types.submodule (
        [
          cfg.shared
          ({ name, ... }:
            {
              gamedir = mkDefault "${config.home.homeDirectory}/${cfg.basePath}/${name}/gamedir";
              _module.args = { inherit pkgs; };
            })
        ] ++ baseModules
      ));
    };
  };

  config.home.file = lib.mapAttrs'
    (name: value:
      {
        name = "${cfg.basePath}/${name}/run";
        value.source = "${value.runners.client}/bin/minecraft";
      })
    cfg.versions;
}
