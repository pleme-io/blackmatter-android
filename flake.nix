{
  description = "Blackmatter Android — Android SDK + Emulator + platform tools provisioning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    substrate = {
      url = "github:pleme-io/substrate";
      inputs.nixpkgs.follows = "nixpkgs";
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
