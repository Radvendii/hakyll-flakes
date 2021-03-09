# hakyll-flake-gen

Use this to easily build your hakyll websites using nix.

`hakyll-flake-gen.gen` expects a function from nixpkgs arguments to a set with the following fields:

- `name`: the name of website. this must also be the name of the haskell project and executable generated.
- `website-src`: the directory with the unprocessed website files
- `builder-src`: the directory with the files defining the website builder (e.g. `site.hs`) at a minimum, this must include `package.yaml`, which can refer to files wherever it wants, I suppose.
- `buildInputs`: any runtime inputs the builder needs to build the  website.

# Example

## `flake.nix`
```
{
  description = "My Website";
  inputs.hakyll-flake.url = "github:Radvendii/hakyll-flake-gen";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, hakyll-flake, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      hakyll-flake.gen."${system}" (
        { pkgs, ... }:
        {
          name = "my-website";
          website-src = ./src;
          builder-src = ./builder;
          buildInputs = with pkgs; [
            rubber
            texlive.combined.scheme-full
            poppler_utils
          ];
        }
      )
    );
}
```

## `builder/package.yaml`
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

- `nix run . -- watch` This will compile and run your website builder, creating the `_site` directory and loading the website at `localhost:8000`. It will also rebuild the website if you change the files (but not if you change `site.hs`)
- `nix build .#builder` (or just `nix build`) this builds the website *builder*. `You can find it at result/bin/<project name>`.
- `nix build .#website` this goes through the whole process for you and simply produces a `result/` symlink with your compiled website inside.
