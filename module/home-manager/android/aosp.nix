# ROM / AOSP development: repo, build tools
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages;

  toolMap = mkSafeToolMap {
    all = { git-repo = pkgs.git-repo or null; };
  };
in {
  config = mkMerge [
    { blackmatter.components.android._internal.allToolNames = attrNames toolMap; }
    (mkIf cfg.enable { home.packages = mkEnabledPackages toolMap cfg._internal.enabledTools; })
  ];
}
