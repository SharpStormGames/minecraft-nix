---
title: Manual Mods
next: false
---

# Modrinth Mods

Mods can be downloaded from modrinth with the projectId and versionId

### projectSlug
To get the project slug, go to the mod you want to install, and look at the last part of the url (after /project/), you should see something like `fabric-api`.

### versionId
To get the version id, click the version that you want to install, the last item of the Metadata section will be the version id, click it to copy it.

```nix
programs.minecraft = {
  enable = true;
  instances = {
    "example-fabric-instance" = {
      minecraft.version = "1.21";
      fabric.version = "0.16.9";
      fabric.hash = "sha256-HRUNC2lxalF2L0HZR/KSe3qr9SHi0Cg5UGUqUTSsDCA=";
      mods.modrinth = [
        # FabricAPI
        {
          projectSlug = "fabric-api";
          versionId = "UU9QOoeP";
          hash = "sha256-/ElT+BErhihstBa/1ljDwzazBc0HbHbMjPOP6QpXHPU=";
        }
      ];
    };
  };
};