{
  description = "Blackmatter Android — Android SDK + Emulator + platform tools provisioning";

  inputs = {
    nixpkgs.follows = "substrate/nixpkgs";
    substrate = {
      url = "github:pleme-io/substrate";
    };
  };

  outputs = inputs @ { self, nixpkgs, substrate, ... }:
    (import "${substrate}/lib/blackmatter-component-flake.nix") {
      inherit self nixpkgs;
      name = "blackmatter-android";
      description = "Android SDK, Emulator, platform tools, and device management";
      modules.homeManager = import ./module/home-manager {
        hmToolHelpers = import "${substrate}/lib/hm-tool-helpers.nix" { lib = nixpkgs.lib; };
      };
      modules.nixos = ./module/nixos;
    };
}
