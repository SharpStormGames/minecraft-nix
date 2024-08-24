{ config, pkgs, lib, mcversions, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.minecraft;
in
{
  imports = [
    ../runners.nix
    ../downloaders/downloaders.nix
  ];

  options.minecraft = {
    version = mkOption {
      example = "1.18";
      description = "The version of minecraft to use.";
      type = types.nonEmptyStr;
      default = config.internal.requiredMinecraftVersion;
    };
  };

  config.internal =
    let
      normalized =
        pkgs.runCommand "package.json"
          {
            nativeBuildInputs = [ pkgs.jsonnet ];
          }
          ''
            jsonfile="$(find ${mcversions}/history -name '${cfg.version}.json')"
            jsonnet -J ${../jsonnet} --tla-str-file orig_str="$jsonfile" -o $out \
              ${../jsonnet/normalize.jsonnet}
          '';
      module = lib.importJSON normalized;
    in
    # tell nix what attrs to expect to avoid infinite recursion
    {
      inherit (module) minecraftArgs jvmArgs assets javaVersion libraries mainClass;
      clientMappings = module.clientMappings or { };
    };
}
