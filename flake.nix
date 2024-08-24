{
  description = "A Minecraft launcher in nix";
  inputs = { 
    nixpkgs = { url = "github:nixos/nixpkgs?ref=nixos-unstable"; };
    mcversions = { url = "github:yushijinhun/minecraft-version-json-history"; flake = false; };
  };
  outputs = { self, nixpkgs, mcversions }: let pkgs = import nixpkgs { system = "x86_64-linux"; }; in {
    homeManagerModules.minecraft = import ./module/module.nix { inherit (self.lib.x86_64-linux) baseModules; }; isNixOSModule = false;
    homeManagerModule = self.homeManagerModules.minecraft;
    lib.x86_64-linux = import ./lib.nix { inherit self pkgs mcversions; };
  };
}
