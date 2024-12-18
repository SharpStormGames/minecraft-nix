---
title: Forge Installation
---

# Forge Installation

To install Forge, you need to pick a loader version that is compatible with the selected minecraft version. You can see which loader versions work with your mc version [here](https://files.minecraftforge.net/net/minecraftforge/forge/)

```nix
programs.minecraft = {
  enable = true;
  instances = {
    "your-forge-instance-name" = {
      minecraft.version = "1.21";
      forge.version = "51.0.33";
      forge.hash = "";
    };
  };
};
```

Leave forge.hash blank and rebuild, nix will tell you what hash to use.