---
title: Initial Setup
---

# Initial Setup

Add the flake input 
```nix
# flake.nix
inputs = {
  minecraft-nix.url = "github:sharpstormgames/minecraft-nix";
};
```

Import the home-manager module
```nix
inputs.minecraft-nix.homeManagerModules.minecraft
# or use
inputs.minecraft-nix.homeManagerModule
```

Start Configuring!
```nix
programs.minecraft = {
  enable = true;
  instances = {
    "your-instance-name" = {
      minecraft.version = "1.21";
    };
  };
};
```

Rebuild and start minecraft from ~/.minecraft/your-instance-name/run