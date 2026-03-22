{
  description = "Blackmatter Android - platform tools, file transfer, connectivity, development, security, and device management";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    substrate = {
      url = "github:pleme-io/substrate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, substrate, devenv }:
  let
    allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs allSystems;
  in {
    # Home-Manager module — cross-platform tool profiles + SDK composition
    homeManagerModules.default = import ./module/home-manager {
      hmToolHelpers = import "${substrate}/lib/hm-tool-helpers.nix" { lib = nixpkgs.lib; };
    };

    # NixOS module — udev rules for non-root device access
    nixosModules.default = import ./module/nixos;

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = devenv.lib.mkShell {
        inputs = { inherit nixpkgs devenv; };
        inherit pkgs;
        modules = [{
          languages.nix.enable = true;
          packages = with pkgs; [ nixpkgs-fmt nil ];
          git-hooks.hooks.nixpkgs-fmt.enable = true;
        }];
      };
    });
  };
}
