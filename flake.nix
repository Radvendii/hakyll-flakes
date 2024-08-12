{
  description = "Hakyll Website";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";

    # these aren't needed in 23.05, but often a few dependencies have broken
    # versions. this (plus the commented out code below)  is the way one would
    # fix them
    
    # hakyll-src = {
    #   url = "github:jaspervdj/hakyll/v4.13.4.1";
    #   flake = false;
    # };
    # hakyll-sass-src = {
    #   url = "github:meoblast001/hakyll-sass/release-0.2.4";
    #   flake = false;
    # };
  };

  outputs = { self, nixpkgs
  # , hakyll-src, hakyll-sass-src 
  }:
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
          # hakyll = hsSuper.callCabal2nix "hakyll" "${hakyll-src}" { };
          # hakyll-sass = hsSuper.callCabal2nix "hakyll-sass" "${hakyll-sass-src}" { };
        });
      });

      overlays = [ overlay ];

      # this is just nixpkgs.legacyPackages but with an overlay
      pkgs = forAllSystems (system: import nixpkgs { inherit system overlays; });
    in
      {
        inherit pkgs overlay overlays;
        lib = rec {
          mkBuilderPackage = args: (mkAllOutputs args).packages.builder;
          mkWebsitePackage = args: (mkAllOutputs args).packages.website;
          mkDevShell       = args: (mkAllOutputs args).devShell;
          mkApp            = args: (mkAllOutputs args).defaultApp;
          mkAllOutputs = import ./gen.nix pkgs.${system};
        };
      };
}
