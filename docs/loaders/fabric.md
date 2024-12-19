---
title: Fabric Installation
prev: false
---

# Fabric Installation

To install Fabric, you need to set what version of the loader you would like to install. You will most likely want the latest version, and you can view all versions [here](https://github.com/fabricmc/fabric-loader/releases)

```nix
programs.minecraft = {
  enable = true;
  instances = {
    "your-fabric-instance-name" = {
      minecraft.version = "1.21";
      fabric.version = "0.16.9";
      fabric.hash = "sha256-HRUNC2lxalF2L0HZR/KSe3qr9SHi0Cg5UGUqUTSsDCA=";
    };
  };
};
```
::: tip
Leave fabric.hash blank and rebuild, nix will tell you what hash to use.
:::