# Security & reverse engineering: APK analysis, decompilers, instrumentation
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages;

  toolMap = mkSafeToolMap {
    all = {
      apktool = pkgs.apktool or null;
      apkid = pkgs.apkid or null;
      apkleaks = pkgs.apkleaks or null;
      apksigcopier = pkgs.apksigcopier or null;
      jadx = pkgs.jadx or null;
      dex2jar = pkgs.dex2jar or null;
      enjarify = pkgs.enjarify or null;
      cfr = pkgs.cfr or null;
      procyon = pkgs.procyon or null;
      bytecode-viewer = pkgs.bytecode-viewer or null;
      frida-tools = pkgs.frida-tools or null;
      jnitrace = pkgs.jnitrace or null;
      androguard = pkgs.androguard or null;
      quark-engine = pkgs.quark-engine or null;
      trueseeing = pkgs.trueseeing or null;
      mitmproxy = pkgs.mitmproxy or null;
      mvt = pkgs.mvt or null;
      diffoscope = pkgs.diffoscope or null;
    };
  };
in {
  config = mkMerge [
    { blackmatter.components.android._internal.allToolNames = attrNames toolMap; }
    (mkIf cfg.enable { home.packages = mkEnabledPackages toolMap cfg._internal.enabledTools; })
  ];
}
