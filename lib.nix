{ self, pkgs, ... }: {

mkMinecraft = mod:
  let result =
    pkgs.lib.evalModules {
      modules = [
        mod
        { _module.args = { inherit pkgs; }; }
      ] ++ self.baseModules;
    };
  in
    result.config.runners.client;
}
