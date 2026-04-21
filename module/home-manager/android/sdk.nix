# SDK composition: androidenv + android-nixpkgs fallback
#
# When the android-nixpkgs overlay is applied (pkgs.androidSdk exists),
# uses it for daily-updated SDK packages. Otherwise falls back to
# nixpkgs androidenv.composeAndroidPackages.
#
# All `pkgs` references are deferred into the `config = mkIf cfg.enable (...)`
# body. Pre-computing `hasAndroidNixpkgs = pkgs ? androidSdk` in the
# top-level let-binding caused infinite recursion during NixOS eval:
# HM evaluating `home-manager.users.<u>._module.freeformType` forced
# the module body, which forced `_module.args.pkgs`, which forced the
# user's config, which re-entered this module. Deferring into mkIf keeps
# the module body inert unless android is actually enabled.
{ lib, pkgs, config, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
in {
  config = mkIf (cfg.enable && cfg.sdk.enable) (
    let
      hasAndroidNixpkgs = pkgs ? androidSdk;
    in
    if hasAndroidNixpkgs then
      # ── android-nixpkgs path (daily-updated, immutable) ───────────────
      let sdk = pkgs.androidSdk cfg.sdk.androidNixpkgsPackages;
      in {
        home.packages = [ sdk ];
        home.sessionVariables = {
          ANDROID_HOME = "${sdk}/share/android-sdk";
          ANDROID_SDK_ROOT = "${sdk}/share/android-sdk";
        };
      }
    else
      # ── androidenv path (nixpkgs built-in) ────────────────────────────
      let
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          platformToolsVersion = "35.0.2";
          platformVersions = cfg.sdk.platformVersions;
          buildToolsVersions = cfg.sdk.buildToolsVersions;
          includeNDK = cfg.sdk.includeNDK;
          ndkVersions = cfg.sdk.ndkVersions;
          includeCmake = cfg.sdk.includeCmake;
          cmakeVersions = cfg.sdk.cmakeVersions;
          includeEmulator = cfg.sdk.includeEmulator;
          includeSystemImages = cfg.sdk.includeSystemImages;
          systemImageTypes = cfg.sdk.systemImageTypes;
          abiVersions = cfg.sdk.abiVersions;
          useGoogleAPIs = cfg.sdk.useGoogleAPIs;
          includeSources = cfg.sdk.includeSources;
          extraLicenses = cfg.sdk.extraLicenses;
        };
      in {
        home.packages = [ androidComposition.androidsdk ];
        home.sessionVariables = {
          ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
          ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
        };
      }
  );
}
