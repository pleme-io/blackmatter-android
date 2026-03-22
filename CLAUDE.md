# blackmatter-android

Single point of Android exposure — deeply modularized into 10 category
sub-modules following the substrate composition pattern.

## Architecture

```
flake.nix
├── homeManagerModules.default → module/home-manager/
│   └── default.nix (aggregator) → android/
│       ├── default.nix          ← orchestrator: options, profiles, tool resolution
│       ├── platform-tools.nix   ← adb, fastboot, shell aliases
│       ├── transfer.nix         ← scrcpy, localsend, syncthing, MTP tools
│       ├── connectivity.nix     ← KDE Connect, dcnnt (Linux)
│       ├── development.nix      ← Android Studio, Gradle, Kotlin, Flutter, Firebase
│       ├── security.nix         ← apktool, jadx, dex2jar, frida, decompilers
│       ├── devices.nix          ← heimdall, edl, qdl, OTA tools, F-Droid
│       ├── emulation.nix        ← waydroid, genymotion (Linux)
│       ├── profiling.nix        ← perfetto, pidcat, agi
│       ├── aosp.nix             ← git-repo
│       └── sdk.nix              ← androidenv + android-nixpkgs fallback
├── nixosModules.default → module/nixos/
│   └── default.nix              ← udev rules for non-root device access
└── devShells
```

### Cross-Module Communication

The orchestrator (`default.nix`) defines:
- `_internal.enabledTools` — resolved tool map (profile + per-tool overrides)
- `_internal.allToolNames` — populated by each sub-module via list merging

Sub-modules read `_internal.enabledTools` to decide which packages to install.
Each sub-module contributes its tool names to `_internal.allToolNames`, which
the `full` profile uses to enable everything.

## Option Tree

```
blackmatter.components.android
├── enable                              # master toggle
├── profile                             # "minimal" | "standard" | "development" | "security" | "full"
├── tools                               # per-tool overrides: { jadx.enable = true; }
├── androidHome                         # ANDROID_HOME path
└── sdk
    ├── enable                          # compose full SDK (default: false)
    ├── platformVersions                # ["34" "35"]
    ├── buildToolsVersions              # ["34.0.0"]
    ├── includeNDK / ndkVersions        # NDK
    ├── includeCmake / cmakeVersions    # CMake
    ├── includeEmulator                 # emulator
    ├── includeSystemImages             # system images
    ├── systemImageTypes / abiVersions  # image config
    ├── useGoogleAPIs / includeSources  # extras
    ├── extraLicenses                   # license acceptance
    └── androidNixpkgsPackages          # selector for android-nixpkgs overlay
```

## Profiles

| Profile | Description | Typical tools |
|---------|-------------|---------------|
| `minimal` | Phone interaction | adb, scrcpy |
| `standard` | Daily driver | + localsend, syncthing, adb-sync, perfetto, pidcat |
| `development` | App development | + Android Studio, Gradle, Kotlin, Flutter, Firebase |
| `security` | RE & security research | + apktool, jadx, dex2jar, frida, heimdall |
| `full` | Everything on platform | All tools from all sub-modules |

## Tool Inventory (~55 tools)

### platform-tools.nix (1 tool)
- `adb` — android-tools (adb, fastboot, img2simg, simg2img)

### transfer.nix (8 tools, 3 Linux-only)
- `scrcpy`, `localsend`, `syncthing`, `better-adb-sync`, `android-file-transfer`
- Linux: `gnirehtet`, `go-mtpfs`, `qtscrcpy`, `jmtpfs`, `adbfs-rootless`

### connectivity.nix (2 tools, Linux-only)
- `kdeconnect` (+ HM service activation), `dcnnt`

### development.nix (16 tools)
- IDE: `android-studio`
- Build: `gradle`, `maven`
- Kotlin: `kotlin`, `kotlin-language-server`, `detekt`, `ktlint`
- Cross-platform: `flutter`, `react-native-debugger`
- Firebase: `firebase-tools`
- Packaging: `bundletool`, `apksigner`, `aapt`
- CI/CD: `fastlane`
- Testing: `maestro`, `selendroid`

### security.nix (17 tools)
- APK: `apktool`, `apkid`, `apkleaks`, `apksigcopier`
- Decompilers: `jadx`, `dex2jar`, `enjarify`, `cfr`, `procyon`, `bytecode-viewer`
- Instrumentation: `frida-tools`, `jnitrace`
- Analysis: `androguard`, `quark-engine`, `trueseeing`
- Network: `mitmproxy`
- Forensics: `mvt`
- Binary diff: `diffoscope`

### devices.nix (11 tools, 2 Linux-only)
- Flashing: `heimdall`, `edl`, `qdl`
- Backup: `android-backup-extractor`, `imgpatchtools`
- OTA: `payload-dumper-go`, `avbroot`, `sdat2img`
- F-Droid: `fdroidserver`, `fdroidcl`
- Linux: `universal-android-debloater`, `abootimg`

### emulation.nix (2 tools, Linux-only)
- `waydroid`, `genymotion`

### profiling.nix (3 tools, 1 Linux-only)
- `perfetto`, `pidcat`
- Linux: `agi`

### aosp.nix (1 tool)
- `git-repo`

## Shell Aliases

**ADB aliases** (when `adb` enabled):

| Alias | Command |
|-------|---------|
| `adevices` | `adb devices` |
| `apush` / `apull` | `adb push` / `adb pull` |
| `ashell` | `adb shell` |
| `ainstall` | `adb install` |
| `alogcat` | `adb logcat` |
| `areboot` | `adb reboot` |
| `awireless` | `adb tcpip 5555` |
| `aconnect` | `adb connect` |
| `ascreenshot` | Capture screenshot to local file |
| `ascreenrecord` | Start screen recording |

**Gradle aliases** (when `gradle` enabled):

| Alias | Command |
|-------|---------|
| `gw` | `./gradlew` |
| `gwb` / `gwc` / `gwt` | `./gradlew build/clean/test` |
| `gwid` | `./gradlew installDebug` |

## SDK Composition

Two backends, automatic selection:

1. **android-nixpkgs** (preferred) — when `pkgs.androidSdk` exists (overlay applied),
   uses daily-updated packages from Google's repository
2. **androidenv** (fallback) — built-in nixpkgs, no extra flake input needed

To use android-nixpkgs, add to your nix repo:
```nix
# flake.nix input:
android-nixpkgs.url = "github:tadfisher/android-nixpkgs/stable";

# overlay:
nixpkgs.overlays = [ android-nixpkgs.overlays.default ];
```

The module detects the overlay automatically — no configuration change needed.

## NixOS Module

For Linux nodes, enable udev rules for non-root ADB/fastboot:
```nix
blackmatter.android.udev.enable = true;
```

## Per-Tool Overrides

```nix
blackmatter.components.android = {
  enable = true;
  profile = "standard";
  tools = {
    jadx.enable = true;        # add from security profile
    syncthing.enable = false;   # remove from standard profile
  };
};
```

## Platform Notes

- **macOS**: ~40 cross-platform tools available. No udev, no waydroid/genymotion, no KDE Connect service.
- **Linux**: ~55 tools total. udev rules via NixOS module. KDE Connect HM service auto-activated.
- **Nix lazy evaluation**: Disabled tools never evaluate their package expressions, so packages that don't exist on a platform won't cause errors unless explicitly enabled.
