{
  description = "Hakyll Website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    hakyll-src = {
      url = "github:jaspervdj/hakyll";
      flake = false;
    };
    hakyll-sass-src = {
      url = "github:meoblast001/hakyll-sass";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, hakyll-src, hakyll-sass-src }:
    let
      # taken from nixpkgs flake.nix
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];

      # taken from nixpkgs flake.nix
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      overlay = (self: super: {
        haskellPackages = super.haskellPackages.extend (hsSelf: hsSuper: {
          hakyll = hsSuper.callCabal2nix "hakyll" "${hakyll-src}" { };
          hakyll-sass = hsSuper.callCabal2nix "hakyll-sass" "${hakyll-sass-src}" { };
        });
      });

      overlays = [ overlay ];

      # this is just nixpkgs.legacyPackages but with an overlay
      pkgs = forAllSystems (system: import nixpkgs { inherit system overlays; });
    in
      {
        inherit pkgs overlay overlays;
        gen = import ./gen.nix pkgs;
      };
}
