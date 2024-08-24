{
  description = "A Minecraft launcher in nix";

  inputs = { 
    nixpkgs = { url = "github:nixos/nixpkgs?ref=nixos-unstable"; };
    mcversions = { url = "github:yushijinhun/minecraft-version-json-history"; flake = false; };
  };

  outputs = { self, nixpkgs, mcversions }: let pkgs = import nixpkgs { system = "x86_64-linux"; }; in {
    nixosModules.home-manager.minecraft = import ./home-manager.nix { inherit (self.lib) baseModules; };
    lib.x86_64-linux = import ./lib.nix { inherit self pkgs; };
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
  };
}
