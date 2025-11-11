{
  description = "Hakyll Website";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";

    # these aren't needed in 25.05, but often a few dependencies have broken
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
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      pkgs = nixpkgs.legacyPackages.${system};

      # overlay = self: super: {
      #   haskellPackages = super.haskellPackages.extend (hsSelf: hsSuper: {
      #     hakyll = hsSuper.callCabal2nix "hakyll" "${hakyll-src}" { };
      #     hakyll-sass = hsSuper.callCabal2nix "hakyll-sass" "${hakyll-sass-src}" { };
      #   });
      # };
      # overlays = [ overlay ];
      # pkgs = import nixpkgs { inherit system overlays; };

      inherit (pkgs) stdenv glibcLocales mkShell haskellPackages;
      name = "my-website";
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./src
          ./site.hs
          ./package.yaml
        ];
      };
      builder = haskellPackages.callCabal2nix name src {};
      haskell-env = pkgs.ghc.withHoogle (hp: with hp; [ haskell-language-server cabal-install ] ++ builder.buildInputs);
      websiteBuildInputs = with pkgs; [
        # other inputs you need to build the website. e.g.
        # rubber
        # texliveFull
        # poppler_utils
      ];
    in {
      packages.${system} = rec {
        inherit builder;
        default = website;
        website = stdenv.mkDerivation {
          inherit name src;
          buildInputs = [ builder ] ++ websiteBuildInputs;
          LANG = "en_US.UTF-8";
          LC_ALL = "en_US.UTF-8";
          LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
          # don't look in fcaches for this; speeds things up a little
          allowSubstitutes = false;
          buildPhase = ''
            ${name} build
          '';
          installPhase = ''
            cp -R _site $out
          '';
          dontStrip = true;
        };
      };
      devShells.${system}.default = mkShell {
        name = "${name}-env";
        buildInputs = [ haskell-env ] ++ websiteBuildInputs;

        shellHook = ''
          export HAKYLL_ENV="development"

          export HIE_HOOGLE_DATABASE="${haskell-env}/share/doc/hoogle/default.hoo"
          export NIX_GHC="${haskell-env}/bin/ghc"
          export NIX_GHCPKG="${haskell-env}/bin/ghc-pkg"
          export NIX_GHC_DOCDIR="${haskell-env}/share/doc/ghc/html"
          export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
        '';
      };
      apps.${system}.default = {
        type = "app";
        program = builder + "/bin/${name}";
      };
      templates.default = {
        path = ./.;
      };
    };
}
