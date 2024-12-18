---
title: Extra Options
next: false
---

# Extra Options

### gamedir
The directory where worlds, mods and other files are stored. If it's not an absolute path, it's relative to the working directory where you run minecraft.<br>
Can be overwritten with the "MINECRAFT_GAMEDIR" environment variable.
```nix
programs.minecraft = {
  enable = true;
  instances= {
    "example-instance" = {
      minecraft.version = "1.21";
      gamedir = "./1.21-gamedir"
    };
  };
};
```

### extraGameDirFiles
A list of files to be copied to the game directory on game startup

```nix
programs.minecraft = {
  enable = true;
  instances = {
    "example-instance" = {
      minecraft.version = "1.21";
      extraGamedirFiles = [
        {
          path = "./options.txt";
          source = "${config.home.homeDirectory}/.minecraft/options.txt";
        }
      ];
    };
  };
};
```

### cleanFiles
Files and directories relative to the game directory to delete on every startup. 

```nix
programs.minecraft = {
  enable = true;
  instances = {
    "example-instance" = {
      minecraft.version = "1.21";
      cleanFiles = [ "logs" ];
    };
  };
};