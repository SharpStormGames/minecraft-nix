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
      fabric.hash = "";
    };
  };
};
```

Leave quilt.hash blank and rebuild, nix will tell you what hash to use.