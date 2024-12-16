{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.modpack.ftb;

  json = lib.importJSON (pkgs.fetchurl {
    url = "https://api.modpacks.ch/public/modpack/${toString cfg.id}/${toString cfg.version}";
    inherit (cfg) hash;
  });

  files = map
    (f: {
      path = "${f.path}/${f.name}";
      source = pkgs.fetchurl {
        inherit (f) sha1;
        url = builtins.replaceStrings [ " " ] [ "%20" ] f.url;
        name = lib.strings.sanitizeDerivationName f.name;
        curlOpts = "--globoff"; # do not misinterpret [] brackets
      };
    })
    (builtins.filter (f: !f.serveronly) json.files);

  forgeVersion = (lib.findFirst
    (t: t.name == "forge")
    (throw "forge not found in modpack targets")
    json.targets).version;

  mcVersion = (lib.findFirst
    (t: t.name == "minecraft")
    (throw "minecraft not found in modpack targets")
    json.targets).version;
in
{
  options.modpack.ftb = {
    id = mkOption {
      example = 25;
      default = null;
      type = types.nullOr types.ints.unsigned;
      description = ''
        The ID of the modpack you want to install.
        To find it go to https://www.feed-the-beast.com/modpack/ ,
        select your modpack and hover over the title.
        You'll find a string like "Identifier: xx".
      '';
    };
    version = mkOption {
      example = 123;
      type = types.ints.unsigned;
      description = ''
        The version ID you want to install.
        To find it go to https://www.feed-the-beast.com/modpack/ ,
        select your modpack, go to the versons tab and hover over the version.
        You'll find a string like "VersionId: xxxx".
      '';
    };
    hash = mkOption {
      type = types.str;
      description = ''
        The hash of the modpack.
        Leave it empty to have nix tell you what to use.
      '';
    };
  };

  config = mkIf (cfg.id != null) {
    minecraft.version = mcVersion;
    forge.version = forgeVersion;
    extraGamedirFiles = files;
  };
}
