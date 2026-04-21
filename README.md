# blackmatter-android

Cross-platform Android developer setup — Android SDK + Emulator + platform
tools via home-manager, plus NixOS udev rules for non-root ADB device access.

## Usage

```nix
{
  inputs.blackmatter-android.url = "github:pleme-io/blackmatter-android";

  outputs = { blackmatter-android, nixosConfigurations, ... }: {
    nixosConfigurations.dev = nixpkgs.lib.nixosSystem {
      modules = [
        blackmatter-android.nixosModules.default
        { blackmatter.components.android.udev.enable = true; }
      ];
    };

    homeConfigurations.you = home-manager.lib.homeManagerConfiguration {
      modules = [
        blackmatter-android.homeManagerModules.default
        ({ ... }: {
          blackmatter.components.android = {
            enable = true;
            sdk.enable = true;
            emulator.enable = true;
          };
        })
      ];
    };
  };
}
```

## License

MIT
