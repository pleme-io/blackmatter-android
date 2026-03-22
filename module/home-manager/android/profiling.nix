# Profiling & debugging: tracing, logging, GPU inspection
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  isLinux = pkgs.stdenv.isLinux;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages;

  toolMap = mkSafeToolMap {
    all = {
      perfetto = pkgs.perfetto or null;
      pidcat = pkgs.pidcat or null;
    };
    linux = optionalAttrs isLinux {
      agi = pkgs.agi or null;
    };
  };
in {
  config = mkMerge [
    { blackmatter.components.android._internal.allToolNames = attrNames toolMap; }
    (mkIf cfg.enable { home.packages = mkEnabledPackages toolMap cfg._internal.enabledTools; })
  ];
}
