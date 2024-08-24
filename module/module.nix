{ baseModules }:
{ pkgs, config, lib, ... }:
let
  cfg = config.programs.minecraft;
  inherit (lib) mkOption mkDefault mkEnableOption types;
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
    instances = mkOption {
      default = { };
      description = "Instances of minecraft to install.";
      type = types.attrsOf (types.submodule (
        [
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
    cfg.instances;
}
