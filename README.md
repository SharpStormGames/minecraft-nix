# minecraft.nix

My fork of [Ninlives/minecraft.nix](https://github.com/Ninlives/minecraft.nix) with alot of modifications

### HM Module

| Name | Description |
|------|-------------|
| **mods** | List of mods load by the game. |
| **resourcePacks** | List of resourcePacks available to the game. |
| **shaderPacks** | List of shaderPacks available to the game. The mod for loading shader packs should be add to option ``mods'' explicitly. |
| **authClientID** | The client id of the authentication application. |
| **declarative** | Whether using a declarative way to manage game files. Currently only resource packs and shader packs are managed. |
