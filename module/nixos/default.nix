# NixOS module: Android udev rules for non-root device access
{ lib, config, pkgs, ... }:
with lib; let
  cfg = config.blackmatter.components.android;
in {
  options.blackmatter.components.android = {
    udev.enable = mkEnableOption "Android udev rules for non-root ADB/fastboot access";
  };

  config = mkIf cfg.udev.enable {
    services.udev.packages = [ pkgs.android-udev-rules ];
  };
}
