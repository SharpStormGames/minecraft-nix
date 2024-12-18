{ self, pkgs, mcversions, ... }: {

mkMinecraft = mod:
  let result =
    pkgs.lib.evalModules {
      modules = [
        mod
        { _module.args = { inherit pkgs; }; }
      ] ++ self.baseModules;
    };
  in
  result.config.runners.client;
  baseModules = [
    { _module.args = { inherit mcversions; }; }
    (import ../loaders/forge)
    (import ../loaders/fabric.nix)
    (import ../loaders/liteloader.nix)
    (import ../loaders/quilt.nix)
    (import ../loaders/vanilla.nix)
    (import ../mods/packs/curseforge-modpack.nix)
    (import ../mods/packs/ftb.nix)
    (import ../mods/direct/modrinth.nix)
    (import ./internal.nix)
  ];
}
