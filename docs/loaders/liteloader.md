---
title: Liteloader Installation
---

# Liteloader Installation

You need to provide the direct url to the liteloader version you want to use. Go [here](https://liteloader.com/download), select your minecraft version and select the build type. Then hover over the jar installer link, right click, and copy link.

```nix
programs.minecraft = {
  enable = true;
  instances = {
    "your-liteloader-instance-name" = {
      minecraft.version = "1.12.2";
      liteloader.url = "http://jenkins.liteloader.com/job/LiteLoaderInstaller%201.12.2/lastSuccessfulBuild/artifact/build/libs/liteloader-installer-1.12.2-00-SNAPSHOT.jar";
      liteloader.hash = "sha256-AfxOgCWliIAMBlMTOMC3gdSShuRB5E6yYYIw0fe8jBM=";
    };
  };
};
```
::: tip
Leave liteloader.hash blank and rebuild, nix will tell you what hash to use.
:::