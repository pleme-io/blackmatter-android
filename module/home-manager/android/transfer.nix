# File transfer: scrcpy, localsend, syncthing, adb-sync, MTP tools
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  isLinux = pkgs.stdenv.isLinux;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages;

  toolMap = mkSafeToolMap {
    all = {
      scrcpy = pkgs.scrcpy or null;
      localsend = pkgs.localsend or null;
      syncthing = pkgs.syncthing or null;
      better-adb-sync = pkgs.better-adb-sync or null;
      android-file-transfer = pkgs.android-file-transfer or null;
    };
    linux = optionalAttrs isLinux {
      gnirehtet = pkgs.gnirehtet or null;
      go-mtpfs = pkgs.go-mtpfs or null;
      qtscrcpy = pkgs.qtscrcpy or null;
      jmtpfs = pkgs.jmtpfs or null;
      adbfs-rootless = pkgs.adbfs-rootless or null;
    };
  };
in {
  config = mkMerge [
    { blackmatter.components.android._internal.allToolNames = attrNames toolMap; }
    (mkIf cfg.enable { home.packages = mkEnabledPackages toolMap cfg._internal.enabledTools; })
  ];
}
