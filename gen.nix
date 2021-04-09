pkgsSet:
{ system
, name ? "site"
, src
, websiteBuildInputs ? []
}:
let
  pkgs = pkgsSet.${system};
  builder = pkgs.haskellPackages.callCabal2nix "${name}" "${src}" { };
  haskell-env = pkgs.haskellPackages.ghcWithHoogle (
    hp: with hp;
      [ haskell-language-server cabal-install ] ++ builder.buildInputs
  );
in rec {
  packages = {
    inherit builder;
    website = pkgs.stdenv.mkDerivation {
      inherit name src;
      buildInputs = [ builder ] ++ websiteBuildInputs;
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      # don't look in caches for this; speeds things up a little
      allowSubstitutes = false;
      buildPhase = ''
        ${name} build
      '';
      installPhase = ''
        mkdir -p $out/
        cp -R _site/* $out/
      '';
      dontStrip = true;
    };
  };
  defaultPackage = packages.website;
  devShell = pkgs.mkShell {
    name = "${name}-env";
    buildInputs = [ haskell-env ];

    shellHook = ''
      export HAKYLL_ENV="development"

      export HIE_HOOGLE_DATABASE="${haskell-env}/share/doc/hoogle/default.hoo"
      export NIX_GHC="${haskell-env}/bin/ghc"
      export NIX_GHCPKG="${haskell-env}/bin/ghc-pkg"
      export NIX_GHC_DOCDIR="${haskell-env}/share/doc/ghc/html"
      export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
    '';
  };
  defaultApp = {
    type = "app";
    program = "${builder}/bin/${name}";
  };
}
