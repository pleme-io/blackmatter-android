# Development: IDE, build tools, language toolchains, CI/CD, testing
{ hmToolHelpers }:
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
  inherit (hmToolHelpers) mkSafeToolMap mkEnabledPackages mkConditionalAliases;

  toolMap = mkSafeToolMap {
    all = {
      android-studio = pkgs.android-studio or null;
      gradle = pkgs.gradle or null;
      maven = pkgs.maven or null;
      kotlin = pkgs.kotlin or null;
      kotlin-language-server = pkgs.kotlin-language-server or null;
      detekt = pkgs.detekt or null;
      ktlint = pkgs.ktlint or null;
      flutter = pkgs.flutter or null;
      react-native-debugger = pkgs.react-native-debugger or null;
      firebase-tools = pkgs.firebase-tools or null;
      bundletool = pkgs.bundletool or null;
      apksigner = pkgs.apksigner or null;
      aapt = pkgs.aapt or null;
      fastlane = pkgs.fastlane or null;
      maestro = pkgs.maestro or null;
      selendroid = pkgs.selendroid or null;
    };
  };

  gradleAliases = {
    gw = "./gradlew";
    gwb = "./gradlew build";
    gwc = "./gradlew clean";
    gwt = "./gradlew test";
    gwid = "./gradlew installDebug";
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
      toolName = "gradle";
      aliases = gradleAliases;
    }))
  ];
}
