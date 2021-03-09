{
  description = "Hakyll Website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    hakyll-src = {
      url = "github:jaspervdj/hakyll";
      flake = false;
    };
    hakyll-sass-src = {
      url = "github:meoblast001/hakyll-sass";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, hakyll-src, hakyll-sass-src }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # need the most recent hakyll and hakyll-sass
          overlays = [
            (self: super: {
              haskellPackages = super.haskellPackages.extend (hsSelf: hsSuper: {
                hakyll = hsSuper.callCabal2nix "hakyll" "${hakyll-src}" { };
                hakyll-sass = hsSuper.callCabal2nix "hakyll-sass" "${hakyll-sass-src}" { };
              });
            })
          ];
        };
      in {
        gen = pkgs.callPackage ./. { };
      }
    );
}
