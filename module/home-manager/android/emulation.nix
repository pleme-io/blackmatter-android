# Emulation: waydroid, genymotion (Linux-only)
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  isLinux = pkgs.stdenv.isLinux;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages;

  toolMap = mkSafeToolMap {
    linux = optionalAttrs isLinux {
      waydroid = pkgs.waydroid or null;
      genymotion = pkgs.genymotion or null;
    };
  };
in {
  config = mkMerge [
    { blackmatter.components.android._internal.allToolNames = attrNames toolMap; }
    (mkIf cfg.enable { home.packages = mkEnabledPackages toolMap cfg._internal.enabledTools; })
  ];
}
