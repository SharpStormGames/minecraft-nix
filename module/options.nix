{lib, ... }: 
let
 inherit (lib.types) mkOptionType listOf path package singleLineStr bool;
 inherit (lib.options) mergeEqualOption mkOption;
 inherit (lib.strings) isStringLike hasSuffix;
 jarPath = mkOptionType {
  name = "jarFilePath";
  check = x:
   isStringLike x && builtins.substring 0 1 (toString x) == "/"
   && hasSuffix ".jar" (toString x);
  merge = mergeEqualOption;
 };
 mkInternalOption = type:
  mkOption {
   inherit type;
   visible = false;
   readOnly = true;
  };

in {
 options = {
  mods = mkOption {
   type = listOf path;
   description = "List of mods load by the game.";
   default = [ ];
  };
  resourcePacks = mkOption {
   type = listOf path;
   description = "List of resourcePacks available to the game.";
   default = [ ];
  };
  shaderPacks = mkOption {
   type = listOf path;
   description =
    "List of shaderPacks available to the game. The mod for loading shader packs should be add to option ``mods'' explicitly.";
   default = [ ];
  };
  authClientID = mkOption {
   type = singleLineStr;
   description = "The client id of the authentication application.";
  };
  launcher = mkOption {
   type = package;
   description = "The launcher of the game.";
   readOnly = true;
  };
  declarative = mkOption {
   type = bool;
   description = "Whether using a declarative way to manage game files.";
   default = true;
  };
  libraries.java = mkOption {
   type = listOf jarPath;
   visible = false;
  };
  libraries.native = mkOption {
   type = listOf path;
   visible = false;
  };
  libraries.preload = mkOption {
   type = listOf package;
   visible = false;
  };

  assets.directory = mkInternalOption path;
  assets.index = mkInternalOption singleLineStr;
  mainClass = mkInternalOption singleLineStr;
 };
}