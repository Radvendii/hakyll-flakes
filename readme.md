# hakyll-flakes

Use this to easily build your hakyll websites using nix flakes.

`hakyll-flakes.lib.mk*` takes in a set with the following fields:

- `system`: the system to build for.
- `name`: the name of website. this must also be the name of the haskell project and executable generated.
- `src`: the source directory (usually `./.`), which must contain at a minimum your `package.yaml` or `project-name.cabal` file.
- `buildInputs` (optional): any runtime inputs the builder needs to build the website.

`hakyll-flakes.overlay` is the overlay that `hakyll-flakes` uses internally to get hakyll working (this will not work on an arbitrary version of nixpkgs), and `hakyll-flake.pkgs` is the legacyPackages that `hakyll-flakes` uses internally (this should always work). If you want to use one consistent nixpkgs set, you can set `buildInputs = with hakyll-flakes.pkgs.${system}; [ ... ]`. Alternatively, you can use your own nixpkgs set for these inputs, there's no reason they need to be the same.

# Example

## `flake.nix`
```
{
  description = "My Website";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.hakyll-flakes.url = "github:Radvendii/hakyll-flakes";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, hakyll-flakes, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (
      system:
      hakyll-flakes.mkAllOutputs {
        inherit system;
        name = "my-website";
        src = ./.;
        websiteBuildInputs = with nixpkgs.legacyPackages.${system}; [
          rubber
          texlive.combined.scheme-full
          poppler_utils
        ];
      }
    );
}
```

## `package.yaml`
```
name: my-website

dependencies:
    - base
    - hakyll
    - filepath
    - pandoc
    - containers
    - time
    - pandoc-types
    - hakyll-sass
    - process
    - bytestring
    - uri-encode
    - text
    - time-locale-compat

executable:
    main: site.hs
```

Then from the top level directory you can run a few different commands:

- `nix build .#website` (or just `nix build`) this goes through the whole process for you and simply produces a `result/` symlink with your compiled website inside.
- `nix build .#builder` this builds the website *builder*, your hakyll-based `site.hs` file. `You can find it at result/bin/<project name>`.
- `nix run . -- watch` This will compile and run your website builder, creating the `_site` directory and loading the website at `localhost:8000`. It will also rebuild the website if you change the files (but not if you change `site.hs`)

You can pick out the individual outputs you want with `mkBuilderPackage`, `mkWebsitePackage`, `mkDevShell`, and `mkApp`.
