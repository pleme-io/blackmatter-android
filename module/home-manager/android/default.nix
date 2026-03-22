# Blackmatter Android — orchestrator
#
# Accepts hmToolHelpers from substrate. Defines master options,
# resolves enabled tools from profile + per-tool overrides.
# Sub-modules use hmToolHelpers for safe package access and enablement checks.
{ hmToolHelpers }:
{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.android;
  isLinux = pkgs.stdenv.isLinux;
  inherit (hmToolHelpers) mkResolvedTools mkProfileToolOptions;

  # ── Profile definitions ───────────────────────────────────────────────
  profileTools = {
    minimal = [
      "adb" "andro" "scrcpy"
    ];

    standard = profileTools.minimal ++ [
      "localsend" "syncthing" "better-adb-sync" "android-file-transfer"
      "perfetto" "pidcat"
    ] ++ optionals isLinux [
      "gnirehtet" "qtscrcpy" "kdeconnect" "agi"
    ];

    development = profileTools.standard ++ [
      "android-studio" "gradle" "kotlin" "kotlin-language-server"
      "detekt" "flutter" "firebase-tools" "maven"
      "bundletool" "apksigner" "aapt" "ktlint"
      "fastlane" "react-native-debugger"
      "maestro" "selendroid"
    ];

    security = profileTools.standard ++ [
      "apktool" "jadx" "dex2jar" "frida-tools" "androguard"
      "bytecode-viewer" "quark-engine" "apkid" "jnitrace"
      "apkleaks" "apksigcopier" "trueseeing" "mvt"
      "heimdall" "edl" "qdl" "mitmproxy" "diffoscope"
      "enjarify" "cfr" "procyon"
      "android-backup-extractor" "imgpatchtools"
    ] ++ optionals isLinux [
      "universal-android-debloater"
    ];

    full = cfg._internal.allToolNames;
  };
in {
  imports = [
    (import ./platform-tools.nix { inherit hmToolHelpers; })
    (import ./transfer.nix { inherit hmToolHelpers; })
    (import ./connectivity.nix { inherit hmToolHelpers; })
    (import ./development.nix { inherit hmToolHelpers; })
    (import ./security.nix { inherit hmToolHelpers; })
    (import ./devices.nix { inherit hmToolHelpers; })
    (import ./emulation.nix { inherit hmToolHelpers; })
    (import ./profiling.nix { inherit hmToolHelpers; })
    (import ./aosp.nix { inherit hmToolHelpers; })
    ./sdk.nix
  ];

  options.blackmatter.components.android = {
    enable = mkEnableOption "android";

    # Profile + tools options from substrate helper
  } // mkProfileToolOptions {
    profiles = [ "minimal" "standard" "development" "security" "full" ];
    defaultProfile = "standard";
    profileDescription = ''
      Tool profile:
      - minimal: adb, scrcpy
      - standard: minimal + localsend, syncthing, adb-sync, perfetto, pidcat
      - development: standard + Android Studio, Gradle, Kotlin, Flutter, Firebase, testing
      - security: standard + apktool, jadx, dex2jar, frida, androguard, heimdall, mitmproxy
      - full: all tools available on this platform
    '';
  } // {
    androidHome = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.android/sdk";
      description = "ANDROID_HOME / ANDROID_SDK_ROOT path";
    };

    sdk = {
      enable = mkEnableOption "Android SDK composition via androidenv";

      platformVersions = mkOption {
        type = types.listOf types.str;
        default = [ "34" "35" ];
      };
      buildToolsVersions = mkOption {
        type = types.listOf types.str;
        default = [ "34.0.0" ];
      };
      includeNDK = mkOption { type = types.bool; default = false; };
      ndkVersions = mkOption {
        type = types.listOf types.str;
        default = [ "26.1.10909125" ];
      };
      includeCmake = mkOption { type = types.bool; default = false; };
      cmakeVersions = mkOption {
        type = types.listOf types.str;
        default = [ "3.22.1" ];
      };
      includeEmulator = mkOption { type = types.bool; default = false; };
      includeSystemImages = mkOption { type = types.bool; default = false; };
      systemImageTypes = mkOption {
        type = types.listOf types.str;
        default = [ "google_apis" ];
      };
      abiVersions = mkOption {
        type = types.listOf types.str;
        default = [ "arm64-v8a" "x86_64" ];
      };
      useGoogleAPIs = mkOption { type = types.bool; default = true; };
      includeSources = mkOption { type = types.bool; default = false; };
      extraLicenses = mkOption {
        type = types.listOf types.str;
        default = [
          "android-sdk-license"
          "android-sdk-preview-license"
          "android-googletv-license"
          "android-sdk-arm-dbt-license"
          "google-gdk-license"
          "intel-android-extra-license"
          "intel-android-sysimage-license"
          "mips-android-sysimage-license"
        ];
      };
      androidNixpkgsPackages = mkOption {
        type = types.functionTo (types.listOf types.package);
        default = sdkPkgs: with sdkPkgs; [
          cmdline-tools-latest
          build-tools-34-0-0
          platform-tools
          platforms-android-34
          platforms-android-35
        ];
      };
    };

    _internal = {
      enabledTools = mkOption {
        type = types.attrsOf types.bool;
        internal = true;
        default = {};
      };
      allToolNames = mkOption {
        type = types.listOf types.str;
        internal = true;
        default = [];
      };
    };
  };

  config = mkIf cfg.enable {
    blackmatter.components.android._internal.enabledTools = mkResolvedTools {
      profileToolNames = profileTools.${cfg.profile};
      toolOverrides = cfg.tools;
    };

    home.sessionVariables = {
      ANDROID_HOME = mkDefault cfg.androidHome;
      ANDROID_SDK_ROOT = mkDefault cfg.androidHome;
    };
  };
}
