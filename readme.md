# hakyll-flake-gen

Use this to easily build your hakyll websites using nix.

`hakyll-flake.gen` takes in a set with the following fields:

- `system`: the system to build for.
- `name`: the name of website. this must also be the name of the haskell project and executable generated.
- `src`: the source directory (usually `./.`), which must contain at a minimum your `package.yaml` or `project-name.cabal` file.
- `buildInputs` (optional): any runtime inputs the builder needs to build the website.

`hakyll-flake.overlay` is the overlay that `hakyll-flake-gen` uses internally to get hakyll working (this is not guaranteed to work on the most recent version of nixpkgs though), and `hakyll-flake.pkgs` is the legacyPackages that `hakyll-flake-gen` uses internally (this should always work). If you want to use one consistent nixpkgs set, you can set `buildInputs = with hakyll-flake.pkgs.${system}; [ ... ]`. Alternatively, you can use your own nixpkgs set for these inputs, there's no reason they need to be the same.

# Example

## `flake.nix`
```
{
  description = "My Website";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.hakyll-flake.url = "github:Radvendii/hakyll-flake-gen";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, hakyll-flake, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (
      system:
      hakyll-flake.gen (
        {
          inherit system;
          name = "my-website";
          src = ./.;
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            rubber
            texlive.combined.scheme-full
            poppler_utils
          ];
        }
      )
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
