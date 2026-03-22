# Device management: flashing, backups, OTA extraction, app stores
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  isLinux = pkgs.stdenv.isLinux;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages;

  toolMap = mkSafeToolMap {
    all = {
      heimdall = pkgs.heimdall or null;
      edl = pkgs.edl or null;
      qdl = pkgs.qdl or null;
      android-backup-extractor = pkgs.android-backup-extractor or null;
      imgpatchtools = pkgs.imgpatchtools or null;
      payload-dumper-go = pkgs.payload-dumper-go or null;
      avbroot = pkgs.avbroot or null;
      sdat2img = pkgs.sdat2img or null;
      fdroidserver = pkgs.fdroidserver or null;
      fdroidcl = pkgs.fdroidcl or null;
    };
    linux = optionalAttrs isLinux {
      universal-android-debloater = pkgs.universal-android-debloater or null;
      abootimg = pkgs.abootimg or null;
    };
  };
in {
  config = mkMerge [
    { blackmatter.components.android._internal.allToolNames = attrNames toolMap; }
    (mkIf cfg.enable { home.packages = mkEnabledPackages toolMap cfg._internal.enabledTools; })
  ];
}
