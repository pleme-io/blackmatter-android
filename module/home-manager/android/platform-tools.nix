# Platform tools: adb, fastboot, img2simg, simg2img
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages mkConditionalAliases;

  toolMap = mkSafeToolMap {
    all = {
      adb = pkgs.android-tools or null;
      andro = pkgs.andro or null;
    };
  };

  aliases = {
    adevices = "adb devices";
    apush = "adb push";
    apull = "adb pull";
    ashell = "adb shell";
    ainstall = "adb install";
    alogcat = "adb logcat";
    areboot = "adb reboot";
    awireless = "adb tcpip 5555";
    aconnect = "adb connect";
    ascreenshot = "adb exec-out screencap -p > screenshot.png && echo screenshot.png";
    ascreenrecord = "adb shell screenrecord /sdcard/recording.mp4";
  };
in {
  config = mkMerge [
    { blackmatter.components.android._internal.allToolNames = attrNames toolMap; }

    (mkIf cfg.enable {
      home.packages = mkEnabledPackages toolMap cfg._internal.enabledTools;
    })

    (mkIf cfg.enable (mkConditionalAliases {
      inherit config;
      enabledTools = cfg._internal.enabledTools;
      toolName = "adb";
      inherit aliases;
    }))
  ];
}
