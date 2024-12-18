---
title: Quilt Installation
next: false
---

# Quilt Installation

To install Quilt, you need to set what version of the loader you would like to install. You will most likely want the latest stable version, and you can view all versions [here](https://github.com/quiltmc/quilt-loader/tags)

```nix
programs.minecraft = {
  enable = true;
  instances = {
    "your-quilt-instance-name" = {
      minecraft.version = "1.21";
      quilt.version = "0.16.9";
      quilt.hash = "";
    };
  };
};
```

Leave quilt.hash blank and rebuild, nix will tell you what hash to use.