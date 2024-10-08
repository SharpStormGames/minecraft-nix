# minecraft-nix

Declarative multi-instance minecraft through Home-Manager

Currently offline-only, Login Support Will be added.

Currently Supported:
- [Forge](https://github.com/MinecraftForge)
- [Fabric](https://fabricmc.net/)
- [Liteloader](https://www.liteloader.com) 
- [CurseForge Modpacks](https://www.curseforge.com/minecraft/modpacks)
- [Feed The Beast Modpacks](https://www.feed-the-beast.com/)

Coming Soon:
- [Modrinth Modpacks](https://modrinth.com/modpacks)
- [Neoforge (maybe)](https://neoforged.net/)
- [Quilt](https://quiltmc.org/en/)
- [Resource Packs - Curseforge](https://curseforge.com/minecraft/texture-packs)
- [Resource Packs - Modrinth](https://modrinth.com/resourcepacks)
- [Shader Packs - CurseForge](https://curseforge.com/minecraft/shaders)
- [Shader Packs - Modrinth](https://modrinth.com/shaders)

## Usage

Add the Flake input
```nix
inputs.minecraft-nix.url = "github:sharpstormgames/minecraft-nix";
```
Import the home-manager module
```nix
inputs.minecraft-nix.homeManagerModule
```

Write your configuration at `programs.minecraft.instances.<name>`, where `<name>`
is some string identifying that installation. You can have as many installations as you want.

All installations will have a directory at `${programs.minecraft.basePath}/<name>/`
(by default `~/.minecraft/<name>/`), which contains the game directory `gamedir`
(where your worlds and settings are saved) and an executable named `run` which
starts Minecraft.

### Example
```nix
{
  programs.minecraft = {
    instances = {
      "vanilla18" = {
        minecraft.version = "1.18";
      };
      "projectozone3" = {
        modpack.curseforge = {
          projectId = 256289;
          fileId = 3590506;
          hash = "sha256-sm1JihpKd8OeW5t8E4+/wCgAnD8/HpDCLS+CvdcNmqY=";
        };
        forge.hash = "sha256-5lQKotcSIgRyb5+MZIEE1U/27rSvwy8Wmb4yCagvsbs=";
      };
    };
  };
}
```

##

This project is a fork of the unmaintained project [12Boti/nix-minecraft](https://github.com/12Boti/nix-minecraft)
