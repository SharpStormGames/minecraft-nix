---
title: Manual Mods
---

# Manual Mods

Mods can be downloaded from their download urls through pkgs.fetchurl

```nix
programs.minecraft = {
  enable = true;
  instances = {
    "example-fabric-instance" = {
      minecraft.version = "1.21";
      fabric.version = "0.16.9";
      fabric.hash = "sha256-HRUNC2lxalF2L0HZR/KSe3qr9SHi0Cg5UGUqUTSsDCA=";
      mods.manual = map pkgs.fetchurl [
        # FabricAPI from CurseForge
        {
          url = "https://mediafilez.forgecdn.net/files/5605/482/fabric-api-0.102.0%2B1.21.jar";
          hash = "sha256-fsDloR53lX/h7QMoSHkhqCEbt+rOFCmM10Y1vsYaPyY=";
        }
      ];
    };
  };
};