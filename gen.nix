pkgsSet:
{ system
, name ? "site"
# src is never used directly, so this only gets triggered if src is not defined *and* one of website-src or builder-src is not defined
, src ? throw "For hakyll-flake.gen you must define either `src` or `website-src` and `builder-src`"
, website-src ? src
, builder-src ? src
, buildInputs ? []
}:
let
  pkgs = pkgsSet.${system};
  builder = pkgs.haskellPackages.callCabal2nix "${name}" "${builder-src}" { };
  haskell-env = pkgs.haskellPackages.ghcWithHoogle (
    hp: with hp;
      [ haskell-language-server cabal-install ] ++ builder.buildInputs
  );
in rec {
  packages = {
    inherit builder;
    website = pkgs.stdenv.mkDerivation {
      inherit name;
      buildInputs = [ builder ] ++ buildInputs;
      src = website-src;
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
    name = "website-env";
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
