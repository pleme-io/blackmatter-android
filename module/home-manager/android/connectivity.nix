# Device connectivity: KDE Connect, dcnnt (Linux-only)
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  isLinux = pkgs.stdenv.isLinux;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages;

  toolMap = mkSafeToolMap {
    linux = optionalAttrs isLinux {
      kdeconnect = pkgs.kdePackages.kdeconnect-kde or null;
      dcnnt = pkgs.dcnnt or null;
    };
  };
in {
  config = mkMerge [
    { blackmatter.components.android._internal.allToolNames = attrNames toolMap; }

    (mkIf cfg.enable {
      home.packages = mkEnabledPackages toolMap cfg._internal.enabledTools;
      services.kdeconnect.enable = mkIf (isLinux && (cfg._internal.enabledTools.kdeconnect or false)) true;
    })
  ];
}
