{
  description = "A Minecraft launcher in nix";

  inputs = { 
    nixpkgs = { url = "github:nixos/nixpkgs?ref=nixos-unstable"; };
    mcversions = { url = "github:yushijinhun/minecraft-version-json-history"; flake = false; };
  };

  outputs = { self, nixpkgs, mcversions }: let pkgs = import nixpkgs { system = "x86_64-linux"; }; in {
    nixosModules.home-manager.minecraft =
      import ./home-manager.nix { inherit (self.lib) baseModules; };
    lib.x86_64-linux = {
      mkMinecraft = mod:
        let result =
          pkgs.lib.evalModules {
            modules = [
              mod
              { _module.args = { inherit pkgs; }; }
            ] ++ self.lib.x86_64-linux.baseModules;
          };
        in
          result.config.runners.client;
    }
    // {
      baseModules = [
        { _module.args = { inherit mcversions; }; }
        (import ./src/internal.nix)
        (import ./src/minecraft.nix)
        (import ./src/forge)
        (import ./src/curseforge.nix)
        (import ./src/modrinth.nix)
        (import ./src/ftb.nix)
        (import ./src/liteloader.nix)
        (import ./src/fabric.nix)
        (import ./src/curseforge-modpack.nix)
      ];
    };

    templates.default = {
      path = ./template;
      description = "A simple flake for vanilla minecraft";
      welcomeText = ''
        Make sure to change the username and game directory!
        For the list of all available options, visit https://12boti.github.io/nix-minecraft/
      '';
    };
  };
}
