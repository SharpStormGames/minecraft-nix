{
  description = "A Minecraft launcher in nix";
  inputs = { 
    nixpkgs = { url = "github:nixos/nixpkgs?ref=nixos-unstable"; };
    mcversions = { url = "github:yushijinhun/minecraft-version-json-history"; flake = false; };
  };
  outputs = { self, nixpkgs, mcversions }: let pkgs = import nixpkgs { system = "x86_64-linux"; }; in {
    homeManagerModules.minecraft = import ./module/module.nix { inherit (self.lib.x86_64-linux) baseModules; }; isNixOSModule = false;
    homeManagerModules.default = self.homeManagerModules.minecraft;
    homeManagerModule = self.homeManagerModules.minecraft;
    lib.x86_64-linux = import ./lib.nix { inherit self pkgs mcversions; };
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs.python3Packages; [  
        colorama
        pyjwt
        requests
        virtualenv
      ];
    };
  };
}
