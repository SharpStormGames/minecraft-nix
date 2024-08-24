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
    (import ./module/loaders/forge)
    (import ./module/loaders/fabric.nix)
    (import ./module/loaders/liteloader.nix)
    (import ./module/loaders/vanilla.nix)
    (import ./module/modpacks/curseforge-modpack.nix)
    (import ./module/modpacks/ftb.nix)
    (import ./module/mods/curseforge.nix)
    (import ./module/mods/modrinth.nix)
    (import ./module/internal.nix)
  ];
}
